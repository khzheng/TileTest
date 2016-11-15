//
//  Level1Scene.m
//  TileTest
//
//  Created by Ken Zheng on 10/6/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "Level1Scene.h"
//#import "Tower.h"
//#import "Enemy.h"
#import "MovementComponent.h"
#import "FiringComponent.h"
#import "HealthComponent.h"

@interface Level1Scene()

@property (nonatomic, strong) SKCameraNode *cameraNode;
@property (nonatomic, strong) SKTileMapNode *road;
@property (nonatomic, strong) SKTileMapNode *grass;

@property (nonatomic, strong) GKGridGraph *graph;
@property (nonatomic, strong) GKGridGraph *openTowersGraph;

@property (nonatomic, strong) GKGridGraphNode *spawnNode;
@property (nonatomic, strong) GKGridGraphNode *endNode;
@property (nonatomic, strong) NSMutableArray *towers;
@property (nonatomic, strong) NSMutableArray *enemies;

@property (nonatomic, assign) NSTimeInterval previousTime;

@end

@implementation Level1Scene

- (void)didMoveToView:(SKView *)view {
    self.cameraNode = [[SKCameraNode alloc] init];
    self.camera = self.cameraNode;
    [self addChild:self.cameraNode];
    self.cameraNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerAction:)];
    [view addGestureRecognizer:pinchRecognizer];
    
    // load scene nodes
    self.road = (SKTileMapNode *)[self childNodeWithName:@"road"];
    self.grass = (SKTileMapNode *)[self childNodeWithName:@"grass"];
    
    // create graph
    self.graph = [GKGridGraph graphFromGridStartingAt:(vector_int2){0, 0} width:(int)self.road.numberOfColumns height:(int)self.road.numberOfRows diagonalsAllowed:NO];
    self.openTowersGraph = [GKGridGraph graphFromGridStartingAt:(vector_int2){0, 0} width:(int)self.road.numberOfColumns height:(int)self.road.numberOfRows diagonalsAllowed:NO];
    // find walls
    NSMutableArray *roadWalls = [NSMutableArray array];
    NSMutableArray *openTowersWalls = [NSMutableArray array];
    for (int col = 0; col < self.road.numberOfColumns; col++) {
        for (int row = 0; row < self.road.numberOfRows; row++) {
            SKTileDefinition *tileDef = [self.road tileDefinitionAtColumn:col row:row];
            if (tileDef == nil) {
                [roadWalls addObject:[self.graph nodeAtGridPosition:(vector_int2){col, row}]];
            } else {
                [openTowersWalls addObject:[self.openTowersGraph nodeAtGridPosition:(vector_int2){col, row}]];
            }
        }
    }
    // remove walls
    [self.graph removeNodes:roadWalls];
    [self.openTowersGraph removeNodes:openTowersWalls];
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    self.spawnNode = [self.graph nodeAtGridPosition:(vector_int2){6,23}];
    self.endNode = [self.graph nodeAtGridPosition:(vector_int2){31,0}];
    
    self.towers = [NSMutableArray array];
    
//    [self drawGrid];
    
    // schedule enemies
    self.enemies = [NSMutableArray array];
    
    [self addChild:[self playButtonNode]];
}

- (SKSpriteNode *)playButtonNode {
    SKSpriteNode *playNode = [SKSpriteNode spriteNodeWithImageNamed:@"play-button.png"];
    playNode.position = [self positionForTileCoordinate:CGPointMake(self.spawnNode.gridPosition.x, self.spawnNode.gridPosition.y - 2)];
    playNode.name = @"playButtonNode";
    playNode.size = CGSizeMake(240, 90);
    playNode.zPosition = CGFLOAT_MAX;
    return playNode;
}

- (void)update:(NSTimeInterval)currentTime {
    for (GKEntity *tower in self.towers) {
        [tower updateWithDeltaTime:currentTime];
    }
}

- (void)createEnemiesAtSpawnPoint:(vector_int2)spawnPoint moveToDestination:(vector_int2)destination {
    for (int i = 0; i < 20; i++) {
        GKEntity *enemy = [GKEntity entity];
        SKSpriteNode *enemySprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        enemySprite.size = self.road.tileSize;
        enemySprite.position = [self positionForTileCoordinate:CGPointMake(spawnPoint.x, spawnPoint.y)];
        enemySprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemySprite.size.width/2];
        enemySprite.physicsBody.categoryBitMask = 2;
        enemySprite.physicsBody.contactTestBitMask = 1;
        enemySprite.physicsBody.collisionBitMask = 0;
        
        MovementComponent *movementComponent = [[MovementComponent alloc] initWithScene:self sprite:enemySprite coordinate:spawnPoint destination:destination];
        [enemy addComponent:movementComponent];
        
        HealthComponent *healthComponent = [[HealthComponent alloc] initWithHealth:10];
        [enemy addComponent:healthComponent];
        
        [self.enemies addObject:enemy];
    }
    
    NSMutableArray *sequence = [NSMutableArray array];
    for (GKEntity *enemy in self.enemies) {
        SKAction *action = [SKAction runBlock:^{
            MovementComponent *mc = (MovementComponent *)[enemy componentForClass:[MovementComponent class]];
            [mc.sprite addChild:[self healthBarForEntity:enemy]];
            [self addChild:mc.sprite];
            
            NSArray *path = [mc pathToDestination];
            [mc followPath:path];
        }];
        
        SKAction *delayAction = [SKAction waitForDuration:1];
        
        [sequence addObjectsFromArray:@[action, delayAction]];
    }
    
    [self runAction:[SKAction sequence:sequence]];
}

- (void)removeEnemy:(GKEntity *)enemy {
    int index = 0;
    SKNode *node = nil;
    for (GKEntity *e in self.enemies) {
        if (e == enemy) {
            node = [(MovementComponent *)[e componentForClass:[MovementComponent class]] sprite];
            break;
        }
        index++;
    }
    
    if (node) {
        [node removeAllActions];
        
        [self.enemies removeObjectAtIndex:index];
        
        [node removeFromParent];
    }
    
    if ([self.enemies count] <= 0) {
        [self addChild:[self playButtonNode]];
    }
}

- (void)createTowerAtCoordinate:(vector_int2)coordinate {
    // is the tile eligible for a tower?
    GKGridGraphNode *node = [self.openTowersGraph nodeAtGridPosition:coordinate];
    if (node) {
        GKEntity *towerEntity = [GKEntity entity];
        
        SKNode *sknode = [SKNode node];
        sknode.name = @"Tower";
        sknode.position = [self positionForTileCoordinate:CGPointMake(coordinate.x, coordinate.y)];
        
        SKSpriteNode *towerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"archer"];
        // let's determine direction tower should be facing
        // check all sides, if 1 side is a road, then that should be the direction
        float radians = 0;
        CGPoint topCoor = CGPointMake(coordinate.x, coordinate.y + 1);
        CGPoint bottomCoor = CGPointMake(coordinate.x, coordinate.y - 1);
        CGPoint rightCoor = CGPointMake(coordinate.x + 1, coordinate.y);
        CGPoint leftCoor = CGPointMake(coordinate.x - 1, coordinate.y);
        SKTileDefinition *topTile = [self.road tileDefinitionAtColumn:topCoor.x row:topCoor.y];
        SKTileDefinition *bottomTile = [self.road tileDefinitionAtColumn:bottomCoor.x row:bottomCoor.y];
        SKTileDefinition *rightTile = [self.road tileDefinitionAtColumn:rightCoor.x row:rightCoor.y];
        SKTileDefinition *leftTile = [self.road tileDefinitionAtColumn:leftCoor.x row:leftCoor.y];
        NSMutableArray *roadCoors = [NSMutableArray array];
        if (topTile) [roadCoors addObject:[NSValue valueWithCGPoint:topCoor]];
        if (bottomTile) [roadCoors addObject:[NSValue valueWithCGPoint:bottomCoor]];
        if (rightTile) [roadCoors addObject:[NSValue valueWithCGPoint:rightCoor]];
        if (leftTile) [roadCoors addObject:[NSValue valueWithCGPoint:leftCoor]];
        if ([roadCoors count] == 1) {
            CGPoint coor = [[roadCoors lastObject] CGPointValue];
            CGPoint heading = CGPointMake(coor.x - coordinate.x, coor.y - coordinate.y);
            if (heading.y == 1) radians = 0;
            else if (heading.y == -1) radians = M_PI;
            else if (heading.x == 1) radians = -M_PI/2.0;
            else if (heading.x == -1) radians = M_PI/2.0;
        } else if ([roadCoors count] == 0) {
            radians = 0;
        } else {    // multiple roads, just pick the first one
            // TODO: add a heading picker
            CGPoint coor = [roadCoors[0] CGPointValue];
            CGPoint heading = CGPointMake(coor.x - coordinate.x, coor.y - coordinate.y);
            if (heading.y == 1) radians = 0;
            else if (heading.y == -1) radians = M_PI;
            else if (heading.x == 1) radians = -M_PI/2.0;
            else if (heading.x == -1) radians = M_PI/2.0;
        }
        
        towerSprite.zRotation = radians;
        [sknode addChild:towerSprite];
        
        float radius = 100;
        SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
        circle.strokeColor = [UIColor redColor];
        //        [sknode addChild:circle];
        
        //        SKShapeNode *rectangle = [SKShapeNode shapeNodeWithRect:CGRectMake(-32, 32, 64, radius)];
        //        rectangle.strokeColor = [UIColor redColor];
        //        [sknode addChild:rectangle];
        
        sknode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        sknode.physicsBody.dynamic = NO;
        sknode.physicsBody.categoryBitMask = 1;
        sknode.physicsBody.contactTestBitMask = 2;
        sknode.physicsBody.collisionBitMask = 0;
        
        SKSpriteNode *bulletSprite = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(10, 10)];
        
        VisualComponent *visualComponent = [[VisualComponent alloc] initWithScene:self sprite:sknode bulletSprite:bulletSprite coordinate:coordinate];
        [towerEntity addComponent:visualComponent];
        
        FiringComponent *firingComponent = [[FiringComponent alloc] initWithSprite:towerSprite damage:3 fireRate:0.5];
        [towerEntity addComponent:firingComponent];
        
        [self addChild:visualComponent.sprite];
        
        // remove node from grid
        [self.openTowersGraph removeNodes:@[node]];
        
        [self.towers addObject:towerEntity];
    } else {
        NSLog(@"cannot place tower here: {%d, %d}", coordinate.x, coordinate.y);
    }
}

- (SKSpriteNode *)healthBarForEntity:(GKEntity *)entity {
    MovementComponent *vc = (MovementComponent *)[entity componentForClass:[MovementComponent class]];
    
    CGRect spriteRect = vc.sprite.frame;
    SKSpriteNode *healthBar = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(spriteRect.size.width, 12)];
    
    HealthComponent *hc = (HealthComponent *)[entity componentForClass:[HealthComponent class]];
    if (hc) {
        double remainingHealth = spriteRect.size.width * (float)(hc.health / hc.maxHealth);
        if (remainingHealth < 0)
            remainingHealth = 0;
        
        healthBar.name = @"HealthBar";
        healthBar.size = CGSizeMake(remainingHealth, 1);
        healthBar.position = CGPointMake(0, spriteRect.size.height/2.0 - healthBar.size.height);
    }
    
    return healthBar;
}

- (GKEntity *)enemyForSprite:(SKNode *)sprite {
    for (GKEntity *enemy in self.enemies) {
        MovementComponent *mc = (MovementComponent *)[enemy componentForClass:[MovementComponent class]];
        if (mc && mc.sprite == sprite)
            return enemy;
    }
    
    return nil;
}

//- (void)addAndMoveEnemy {
//    Enemy *enemy = [Enemy nodeWithScene:self position:[self positionForTileCoordinate:CGPointMake(5, 15)]];
//    [self addChild:enemy];
//    [self.enemies addObject:enemy];
//    
//    NSArray *pathNodes = [self.graph findPathFromNode:self.spawnNode toNode:self.endNode];
//    NSMutableArray *moveActions = [NSMutableArray array];
//    
//    for (int i = 1; i < [pathNodes count]; i++) {
//        GKGridGraphNode *node = pathNodes[i];
//        CGPoint destination = [self positionForTileCoordinate:CGPointMake(node.gridPosition.x, node.gridPosition.y)];
//        SKAction *moveAction = [SKAction moveTo:destination duration:0.5];
//        [moveActions addObject:moveAction];
//    }
//    
//    SKAction *sequence = [SKAction sequence:moveActions];
//    
//    [enemy.sprite runAction:sequence];
//}

- (CGPoint)positionForTileCoordinate:(CGPoint)coordinate {
    CGSize tileSize = self.road.tileSize;
    return CGPointMake(coordinate.x * tileSize.width + tileSize.width / 2, coordinate.y * tileSize.height + tileSize.height / 2);
}

- (CGPoint)tileCoordinateForPosition:(CGPoint)position {
    return CGPointMake([self.road tileColumnIndexFromPosition:position], [self.road tileRowIndexFromPosition:position]);
}

- (void)drawGrid {
    CGSize tileSize = self.road.tileSize;
    CGSize mapSize = self.road.mapSize;
    
    // draw horizontal lines
    for (int y = 0; y < mapSize.height; y++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(mapSize.width, 2)];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(0, tileSize.height * y);
        [self addChild:line];
    }
    
    // draw vertical lines
    for (int x = 0; x < mapSize.width; x++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(2, mapSize.height)];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(tileSize.width * x, 0);
        [self addChild:line];
    }
}

- (GKEntity *)towerForSprite:(SKNode *)sprite {
    for (GKEntity *tower in self.towers) {
        VisualComponent *vc = (VisualComponent *)[tower componentForClass:[VisualComponent class]];
        if (vc && vc.sprite == sprite)
            return tower;
    }
    
    return nil;
}

- (void)fireBulletFromEntity:(GKEntity *)entity towardsEnemy:(GKEntity *)enemy angle:(float)angle {
    MovementComponent *enemyMc = (MovementComponent *)[enemy componentForClass:[MovementComponent class]];
    CGPoint enemyPosition = enemyMc.sprite.position;
    
    VisualComponent *entityVc = (VisualComponent *)[entity componentForClass:[VisualComponent class]];
    CGPoint entityPosition = entityVc.sprite.position;

    SKSpriteNode *bulletSprite = entityVc.bulletSprite;
    SKSpriteNode *bulletSpriteCopy = [bulletSprite copy];
    bulletSpriteCopy.position = entityPosition;
    bulletSpriteCopy.zPosition = 1;    // position bullet behind tower?
//    bulletSpriteCopy.zRotation = angle;
    [self addChild:bulletSpriteCopy];
    

    SKAction *trajAction = [SKAction moveTo:enemyPosition duration:0.1];
    [bulletSpriteCopy runAction:trajAction completion:^{
        [self removeChildrenInArray:@[bulletSpriteCopy]];
    }];
}

- (void)updateHealthBarForEnemy:(GKEntity *)enemy {
    SKNode *enemyNode = [(MovementComponent *)[enemy componentForClass:[MovementComponent class]] sprite];
    SKSpriteNode *healthBar = (SKSpriteNode *)[enemyNode childNodeWithName:@"HealthBar"];
    if (healthBar) {
        SKSpriteNode *newHealthBar = [self healthBarForEntity:enemy];
        [enemyNode removeChildrenInArray:@[healthBar]];
        
        HealthComponent *hc = (HealthComponent *)[enemy componentForClass:[HealthComponent class]];
        
        if (hc.health > 0)
            [enemyNode addChild:newHealthBar];
        else
            [self removeEnemy:enemy];
    }
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    [self contactWithNodeA:contact.bodyA.node nodeB:contact.bodyB.node entered:YES];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    [self contactWithNodeA:contact.bodyA.node nodeB:contact.bodyB.node entered:NO];
}

- (void)contactWithNodeA:(SKNode *)nodeA nodeB:(SKNode *)nodeB entered:(BOOL)entered {
    GKEntity *enemy;
    GKEntity *tower;
    if ([[nodeA name] isEqualToString:@"Tower"]) {          // nodeA is tower
        enemy = [self enemyForSprite:nodeB];
        tower = [self towerForSprite:nodeA];
    } else if ([[nodeB name] isEqualToString:@"Tower"]) {   // nodeB is tower
        enemy = [self enemyForSprite:nodeA];
        tower = [self towerForSprite:nodeB];
    }
    
    if (enemy) {
        FiringComponent *fc = (FiringComponent *)[tower componentForClass:[FiringComponent class]];
        if (entered)
            [fc enemyEnteredTowerRange:enemy];
        else
            [fc enemyExitedTowerRange:enemy];
    }
}

#pragma mark - UITouch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint tilePosition = [self tileCoordinateForPosition:touchLocation];
    SKNode *node = [self nodeAtPoint:touchLocation];
    NSLog(@"touched: %@", NSStringFromCGPoint(tilePosition));
    
    if ([node.name isEqualToString:@"playButtonNode"]) {
        [self createEnemiesAtSpawnPoint:self.spawnNode.gridPosition moveToDestination:self.endNode.gridPosition];
        
        [node removeFromParent];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint tilePosition = [self tileCoordinateForPosition:touchLocation];
    vector_int2 coordinate = (vector_int2){tilePosition.x, tilePosition.y};
    
    GKGridGraphNode *node = [self.openTowersGraph nodeAtGridPosition:coordinate];
    if (node) { // can place tower
        [self createTowerAtCoordinate:coordinate];
    } else {    // can't place tower
        // was a tower selected?
        for (GKEntity *tower in self.towers) {
            VisualComponent *vc = (VisualComponent *)[tower componentForClass:[VisualComponent class]];
            if (vc) {
                CGRect spriteRect = CGRectMake(vc.sprite.frame.origin.x - self.road.tileSize.width/2.0, vc.sprite.frame.origin.y - self.road.tileSize.height/2.0, self.road.tileSize.width, self.road.tileSize.height);
                if (CGRectContainsPoint(spriteRect, touchLocation)) {
                    NSLog(@"selectedTower");
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizer events

- (void)panGestureAction:(UIPanGestureRecognizer *)panRecognizer {
    CGPoint translatedPoint = [panRecognizer translationInView:self.view];
    CGPoint cameraPosition = self.cameraNode.position;
    
    self.cameraNode.position = CGPointMake(cameraPosition.x - translatedPoint.x, cameraPosition.y + translatedPoint.y);
    
    // reset
    [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
}

- (void)pinchGestureRecognizerAction:(UIPinchGestureRecognizer *)pinchRecognizer {
    CGPoint locationInView = [pinchRecognizer locationInView:self.view];
    CGPoint location = [self convertPointFromView:locationInView];
    
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        float deltaScale = (pinchRecognizer.scale - 1.0) * 2;
        float convertedScale = pinchRecognizer.scale - deltaScale;
        float newScale = self.cameraNode.xScale * convertedScale;
        [self.cameraNode setScale:newScale];
        
        CGPoint locationAfterScale = [self convertPointFromView:locationInView];
        CGPoint locationDelta = CGPointMake(location.x - locationAfterScale.x, location.y - locationAfterScale.y);
        CGPoint newPoint = CGPointMake(self.cameraNode.position.x + locationDelta.x, self.cameraNode.position.y + locationDelta.y);
        self.cameraNode.position = newPoint;
        pinchRecognizer.scale = 1.0;
    }
}

@end
