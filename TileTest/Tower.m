//
//  Tower.m
//  TileTest
//
//  Created by Ken Zheng on 10/8/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "Tower.h"

@implementation Tower

+ (instancetype)nodeWithScene:(Level1Scene *)levelScene position:(CGPoint)position {
    Tower *tower = [[Tower alloc] init];
    tower.sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Soldier"];
    tower.sprite.position = position;
    [tower addChild:tower.sprite];
    
    tower.levelScene = levelScene;
    
    CGRect circle = CGRectMake(position.x - tower.attackRange, position.y - tower.attackRange, tower.attackRange * 2, tower.attackRange * 2);
    SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
    shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
    shapeNode.strokeColor = [SKColor redColor];
    shapeNode.lineWidth = 2;
    [tower addChild:shapeNode];
    
    return tower;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _attackRange = 100;
    }
    
    return self;
}

@end
