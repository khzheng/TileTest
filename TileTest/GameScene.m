//
//  GameScene.m
//  TileTest
//
//  Created by Ken Zheng on 9/20/16.
//  Copyright (c) 2016 Ken Zheng. All rights reserved.
//

#import "GameScene.h"
#import "Unit.h"
#import "TileData.h"

@interface GameScene()

@property (nonatomic, strong) SKTileMapNode *landBackground;
@property (nonatomic, strong) NSMutableArray *playerUnits;
@property (nonatomic, strong) NSMutableArray *tileData;

@end

@implementation GameScene

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerUnits = [NSMutableArray array];
        _tileData = [NSMutableArray array];
    }
    
    return self;
}

- (void)loadSceneNodes {
    self.landBackground = (SKTileMapNode *)[self childNodeWithName:@"landBackground"];
    
    [self loadTileData];
}

- (void)loadUnits {
    Unit *unit1 = [Unit nodeWithScene:self position:[self positionForTileCoordinate:CGPointMake(2, 2)]];
    Unit *unit2 = [Unit nodeWithScene:self position:[self positionForTileCoordinate:CGPointMake(3, 2)]];
    
    [self addChild:unit1];
    [self addChild:unit2];
}

- (void)loadTileData {
    for (int row = 0; row < self.landBackground.numberOfRows; row++) {
        for (int col = 0; col < self.landBackground.numberOfColumns; col++) {
            SKTileDefinition *tileDef = [self.landBackground tileDefinitionAtColumn:col row:row];
            if (tileDef && tileDef.userData) {
                TileData *tileData = [[TileData alloc] init];
                tileData.tilePosition = CGPointMake(col, row);
                tileData.tileType = tileDef.userData[@"TileType"];
                
                [self.tileData addObject:tileData];
            }
        }
    }
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
    if (tileDef.userData) {
        
    }
    
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

- (void)selectUnit:(Unit *)unit {
    self.selectedUnit = unit;
}

- (void)deselectUnit {
    if (self.selectedUnit)
        [self.selectedUnit deselectUnit];
    self.selectedUnit = nil;
}

- (CGPoint)tileCoordinateForPosition:(CGPoint)position {
    return CGPointMake([self.landBackground tileColumnIndexFromPosition:position], [self.landBackground tileRowIndexFromPosition:position]);
}

- (CGPoint)positionForTileCoordinate:(CGPoint)coordinate {
    CGSize tileSize = [self tileSize];
    return CGPointMake(coordinate.x * tileSize.width + tileSize.width / 2, coordinate.y * tileSize.height + tileSize.height / 2);
}

@end
