//
//  GameScene.m
//  TileTest
//
//  Created by Ken Zheng on 9/20/16.
//  Copyright (c) 2016 Ken Zheng. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()

@property (nonatomic, strong) SKTileMapNode *landBackground;
@property (nonatomic, strong) NSMutableArray *playerUnits;
//@property (nonatomic, strong) SKSpriteNode *spaceship;

@end

@implementation GameScene

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerUnits = [NSMutableArray array];
    }
    
    return self;
}

- (void)loadSceneNodes {
    self.landBackground = (SKTileMapNode *)[self childNodeWithName:@"landBackground"];
//    self.spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//    self.spaceship.position = CGPointMake(640, 640);
//    self.spaceship.size = [self tileSize];
//    [self addChild:self.spaceship];
}

- (void)loadUnits {
    SKSpriteNode *soldier = [SKSpriteNode spriteNodeWithImageNamed:@"Soldier"];
    soldier.position = [self positionForTileCoordinate:CGPointMake(1, 1)];
    [self addChild:soldier];
}

-(void)didMoveToView:(SKView *)view {
    [self loadSceneNodes];
    
    [self loadUnits];
    
    [self drawGrid];
    
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 45;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    CGPoint tileCoord = [self tileCoordinateForPosition:touchLocation];
    SKTileDefinition *tileDef = [self.landBackground tileDefinitionAtColumn:tileCoord.x row:tileCoord.y];
    NSLog(@"userData: %@", tileDef.userData);
    
//    SKAction *moveAction = [SKAction moveTo:touchLocation duration:1.0];
//    [self.spaceship runAction:moveAction];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (CGSize)tileSize {
    return self.landBackground.tileSize;
}

- (void)drawGrid {
    CGSize tileSize = self.landBackground.tileSize;
    CGSize mapSize = self.landBackground.mapSize;
    
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

- (CGPoint)tileCoordinateForPosition:(CGPoint)position {
    return CGPointMake([self.landBackground tileColumnIndexFromPosition:position], [self.landBackground tileRowIndexFromPosition:position]);
}

- (CGPoint)positionForTileCoordinate:(CGPoint)coordinate {
    CGSize tileSize = [self tileSize];
    return CGPointMake(coordinate.x * tileSize.width + tileSize.width / 2, coordinate.y * tileSize.height + tileSize.height / 2);
}

@end
