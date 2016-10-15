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

@interface Level1Scene()

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
    
    self.spawnNode = [self.graph nodeAtGridPosition:(vector_int2){5,15}];
    self.endNode = [self.graph nodeAtGridPosition:(vector_int2){20,5}];
    
    self.towers = [NSMutableArray array];
    
    [self drawGrid];
    
    // schedule enemies
    self.enemies = [NSMutableArray array];
    [self createEnemies];
}

- (void)createEnemies {
    for (int i = 0; i < 10; i++) {
        GKEntity *enemy = [GKEntity entity];
        SKSpriteNode *enemySprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        enemySprite.size = self.road.tileSize;
        enemySprite.position = [self positionForTileCoordinate:CGPointMake(self.spawnNode.gridPosition.x, self.spawnNode.gridPosition.y)];
        enemySprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:enemySprite.size.width/2];
        enemySprite.physicsBody.categoryBitMask = 2;
        enemySprite.physicsBody.contactTestBitMask = 1;
        enemySprite.physicsBody.collisionBitMask = 0;
        
        MovementComponent *movementComponent = [[MovementComponent alloc] initWithScene:self sprite:enemySprite coordinate:self.spawnNode.gridPosition destination:self.endNode.gridPosition];
        [enemy addComponent:movementComponent];
        
        [self.enemies addObject:enemy];
    }
    
    NSMutableArray *sequence = [NSMutableArray array];
    for (GKEntity *enemy in self.enemies) {
        SKAction *action = [SKAction runBlock:^{
            MovementComponent *mc = (MovementComponent *)[enemy componentForClass:[MovementComponent class]];
            [self addChild:mc.sprite];
            
            NSArray *path = [mc pathToDestination];
            [mc followPath:path];
        }];
        
        SKAction *delayAction = [SKAction waitForDuration:1];
        
        [sequence addObjectsFromArray:@[action, delayAction]];
    }
    
    [self runAction:[SKAction sequence:sequence]];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint tilePosition = [self tileCoordinateForPosition:touchLocation];
    
    [self createTowerAtCoordinate:(vector_int2){tilePosition.x, tilePosition.y}];
}

- (void)createTowerAtCoordinate:(vector_int2)coordinate {
    // is the tile eligible for a tower?
    GKGridGraphNode *node = [self.openTowersGraph nodeAtGridPosition:coordinate];
    if (node) {
        GKEntity *towerEntity = [GKEntity entity];
        
        SKNode *sknode = [SKNode node];
        sknode.name = @"Tower";
        sknode.position = [self positionForTileCoordinate:CGPointMake(coordinate.x, coordinate.y)];
        
        SKSpriteNode *towerSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Soldier"];
        [sknode addChild:towerSprite];
        
        float radius = 100;
        SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
        circle.strokeColor = [UIColor redColor];
        [sknode addChild:circle];
        
        sknode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        sknode.physicsBody.dynamic = NO;
        sknode.physicsBody.categoryBitMask = 1;
        sknode.physicsBody.contactTestBitMask = 2;
        sknode.physicsBody.collisionBitMask = 0;
        
        SKSpriteNode *bulletSprite = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(10, 10)];
        
        VisualComponent *visualComponent = [[VisualComponent alloc] initWithScene:self sprite:sknode bulletSprite:bulletSprite coordinate:coordinate];
        [towerEntity addComponent:visualComponent];
        
        FiringComponent *firingComponent = [[FiringComponent alloc] initWithSprite:towerSprite damage:1 fireRate:1];
        [towerEntity addComponent:firingComponent];
        
        [self addChild:visualComponent.sprite];
        
        // remove node from grid
        [self.openTowersGraph removeNodes:@[node]];
        
        [self.towers addObject:towerEntity];
    } else {
        NSLog(@"cannot place tower here: {%d, %d}", coordinate.x, coordinate.y);
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
    
    SKAction *trajAction = [SKAction moveTo:enemyPosition duration:0.2];
    [bulletSpriteCopy runAction:trajAction completion:^{
        [self removeChildrenInArray:@[bulletSpriteCopy]];
    }];
}

- (void)update:(NSTimeInterval)currentTime {
    for (GKEntity *tower in self.towers) {
        [tower updateWithDeltaTime:currentTime];
    }
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

- (void)didBeginContact:(SKPhysicsContact *)contact {
    [self contactWithNodeA:contact.bodyA.node nodeB:contact.bodyB.node entered:YES];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    [self contactWithNodeA:contact.bodyA.node nodeB:contact.bodyB.node entered:NO];
}

@end
