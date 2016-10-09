//
//  Enemy.m
//  TileTest
//
//  Created by Ken Zheng on 10/8/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

+ (instancetype)nodeWithScene:(Level1Scene *)levelScene position:(CGPoint)position {
    Enemy *enemy = [[Enemy alloc] init];
    enemy.sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    enemy.sprite.position = position;
    enemy.sprite.size = CGSizeMake(64, 64);
    [enemy addChild:enemy.sprite];
    
    enemy.levelScene = levelScene;
    
    return enemy;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hp = 10;
    }
    
    return self;
}

@end
