//
//  FiringComponent.h
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
#import <SpriteKit/SpriteKit.h>

@interface FiringComponent : GKComponent

@property (nonatomic, strong) SKSpriteNode *sprite;
@property (nonatomic, assign) float dmgPerBullet;
@property (nonatomic, assign) float fireRate;

- (instancetype)initWithSprite:(SKSpriteNode *)sprite damage:(float)damage fireRate:(float)fireRate;

@end
