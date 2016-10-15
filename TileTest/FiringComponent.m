//
//  FiringComponent.m
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "FiringComponent.h"

@implementation FiringComponent

- (instancetype)initWithSprite:(SKSpriteNode *)sprite damage:(float)damage fireRate:(float)fireRate {
    self = [super init];
    if (self) {
        _sprite = sprite;
        _dmgPerBullet = damage;
        _fireRate = fireRate;
    }
    
    return self;
}

//- (void)updateWithDeltaTime:(NSTimeInterval)seconds {
//    [super updateWithDeltaTime:seconds];
//}

@end
