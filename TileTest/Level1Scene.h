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

@end
