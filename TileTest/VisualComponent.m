//
//  VisualComponent.m
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "VisualComponent.h"

@implementation VisualComponent

- (instancetype)initWithScene:(Level1Scene *)scene
                       sprite:(SKNode *)sprite
                 bulletSprite:(SKSpriteNode *)bulletSprite
                   coordinate:(vector_int2)coordinate {
    self = [super init];
    if (self) {
        _scene = scene;
        _sprite = sprite;
        _bulletSprite = bulletSprite;
        _coordinate = coordinate;
    }
    
    return self;
}

@end
