//
//  Level1Scene.h
//  TileTest
//
//  Created by Ken Zheng on 10/6/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@interface Level1Scene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, readonly, strong) GKGridGraph *graph;

- (CGPoint)positionForTileCoordinate:(CGPoint)coordinate;
- (void)fireBulletFromEntity:(GKEntity *)entity towardsEnemy:(GKEntity *)enemy angle:(float)angle;
- (void)updateHealthBarForEnemy:(GKEntity *)enemy;
- (void)removeEnemy:(GKEntity *)enemy;

@end
