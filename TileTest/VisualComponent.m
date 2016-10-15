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
                       sprite:(SKSpriteNode *)sprite
                   coordinate:(vector_int2)coordinate {
    self = [super init];
    if (self) {
        _scene = scene;
        _sprite = sprite;
        _coordinate = coordinate;
    }
    
    return self;
}

@end
