//
//  HealthComponent.h
//  TileTest
//
//  Created by Ken Zheng on 10/16/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>

@interface HealthComponent : GKComponent

@property (nonatomic, assign) double maxHealth;
@property (nonatomic, assign) double health;

- (instancetype)initWithHealth:(double)health;

@end
