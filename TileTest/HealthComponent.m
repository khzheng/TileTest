//
//  HealthComponent.m
//  TileTest
//
//  Created by Ken Zheng on 10/16/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "HealthComponent.h"

@implementation HealthComponent

- (instancetype)initWithHealth:(double)health {
    self = [super init];
    if (self) {
        _health = _maxHealth = health;
    }
    
    return self;
}

@end
