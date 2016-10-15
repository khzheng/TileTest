//
//  FiringComponent.m
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "FiringComponent.h"
#import "VisualComponent.h"
#import "Level1Scene.h"

@interface FiringComponent()

@property (nonatomic, strong) NSMutableArray *enemiesInRange;

@end

@implementation FiringComponent

- (instancetype)initWithSprite:(SKSpriteNode *)sprite damage:(float)damage fireRate:(float)fireRate {
    self = [super init];
    if (self) {
        _sprite = sprite;
        _dmgPerBullet = damage;
        _fireRate = fireRate;
        
        _enemiesInRange = [NSMutableArray array];
    }
    
    return self;
}

- (void)updateWithDeltaTime:(NSTimeInterval)seconds {
    [super updateWithDeltaTime:seconds];
    
    if ([self.enemiesInRange count] > 0) {
        [self enemyInRange:self.enemiesInRange[0]];
    }
}

- (void)enemyInRange:(GKEntity *)enemy {
    VisualComponent *enemyVc = (VisualComponent *)[enemy componentForClass:[VisualComponent class]];
    SKNode *enemySprite = enemyVc.sprite;
    
    float angle = [self caluclateAngle:[self.sprite parent] node2:enemySprite];
    
    Level1Scene *scene = (Level1Scene *)self.sprite.scene;
    if (scene) {
        [scene fireBulletFromEntity:self.entity towardsEnemy:enemy angle:angle];
    }
}

- (float)caluclateAngle:(SKNode *)node1 node2:(SKNode *)node2 {
    float angle = atan((node1.position.x - node2.position.x) / (node1.position.y - node2.position.y));
    
    if (node2.position.y > node1.position.y)
        angle *= -1;
    else
        angle = M_PI - angle;
    
    return angle;
}

- (void)enemyEnteredTowerRange:(GKEntity *)enemy {
//    NSLog(@"enemyentered");
    [self.enemiesInRange addObject:enemy];
}

- (void)enemyExitedTowerRange:(GKEntity *)enemy {
//    NSLog(@"ewnenmyexited");
    [self.enemiesInRange removeObject:enemy];
}

@end
