//
//  Enemy.h
//  TileTest
//
//  Created by Ken Zheng on 10/8/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level1Scene.h"

@interface Enemy : SKNode

@property (nonatomic, weak) Level1Scene *levelScene;
@property (nonatomic, strong) SKSpriteNode *sprite;
@property (nonatomic, assign) int hp;

+ (instancetype)nodeWithScene:(Level1Scene *)levelScene position:(CGPoint)position;

@end
