//
//  GameScene.h
//  TileTest
//

//  Copyright (c) 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TileData.h"

@class Unit;

@interface GameScene : SKScene

@property (nonatomic, strong) Unit *selectedUnit;

- (void)selectUnit:(Unit *)unit;
- (void)deselectUnit;

- (CGPoint)tileCoordinateForPosition:(CGPoint)position;
- (TileData *)tileDataAtTile:(CGPoint)tilePosition;
- (void)paintMovementTile:(TileData *)tileData;

@end
