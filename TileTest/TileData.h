//
//  TileData.h
//  TileTest
//
//  Created by Ken Zheng on 10/1/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TileData : SKNode

@property (nonatomic, assign) CGPoint tilePosition;
@property (nonatomic, assign) int movementCost;
@property (nonatomic, copy) NSString *tileType;

@end
