//
//  Tower.h
//  TileTest
//
//  Created by Ken Zheng on 10/8/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level1Scene.h"

@interface Tower : SKNode

@property (nonatomic, weak) Level1Scene *levelScene;
@property (nonatomic, assign) int attackRange;
@property (nonatomic, strong) SKSpriteNode *sprite;

+ (instancetype)nodeWithScene:(Level1Scene *)levelScene position:(CGPoint)position;

@end
