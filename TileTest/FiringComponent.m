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
#import "HealthComponent.h"

@interface FiringComponent()

@property (nonatomic, strong) NSMutableArray *enemiesInRange;
@property (nonatomic, strong) GKEntity *targetEnemy;
@property (nonatomic, strong) NSTimer *attackTimer;
@property (nonatomic, assign) BOOL isAttacking;

@end

@implementation FiringComponent

- (instancetype)initWithSprite:(SKSpriteNode *)sprite damage:(float)damage fireRate:(float)fireRate {
    self = [super init];
    if (self) {
        _sprite = sprite;
        _dmgPerBullet = damage;
        _fireRate = fireRate;
        _heading = CGPointZero;
        _isAttacking = NO;
        
        _enemiesInRange = [NSMutableArray array];
    }
    
    return self;
}

- (void)updateWithDeltaTime:(NSTimeInterval)seconds {
    [super updateWithDeltaTime:seconds];
    
    if ([self.enemiesInRange count] > 0) {
        [self enemyInRange:self.enemiesInRange[0]];
    } else {
        self.targetEnemy = nil;
        
        [self stopAttacking];
    }
}

- (void)startAttacking {
    if (self.isAttacking)
        return;
    
    self.isAttacking = YES;
    
    if (self.attackTimer) {
        [self.attackTimer invalidate];
        self.attackTimer = nil;
    }
    
    [self attack];
    self.attackTimer = [NSTimer scheduledTimerWithTimeInterval:self.fireRate target:self selector:@selector(attack) userInfo:nil repeats:YES];
}

- (void)startAttackingTargetEnemy {
    if (self.attackTimer) {
        [self.attackTimer invalidate];
        self.attackTimer = nil;
    }
    
    // start tiemr to fire
    [self attackTargetEnemy];
    self.attackTimer = [NSTimer scheduledTimerWithTimeInterval:self.fireRate target:self selector:@selector(attackTargetEnemy) userInfo:nil repeats:YES];
}

- (void)stopAttacking {
    [self.attackTimer invalidate];
    self.attackTimer = nil;
    
    self.isAttacking = NO;
}

- (void)attackTargetEnemy {
    VisualComponent *enemyVc = (VisualComponent *)[self.targetEnemy componentForClass:[VisualComponent class]];
    SKNode *enemySprite = enemyVc.sprite;
    
    float angle = [self caluclateAngle:[self.sprite parent] node2:enemySprite];
    
    float damage = self.dmgPerBullet;
    
    HealthComponent *hc = (HealthComponent *)[self.targetEnemy componentForClass:[HealthComponent class]];
    hc.health = hc.health - damage;
    
    Level1Scene *scene = (Level1Scene *)self.sprite.scene;
    if (scene) {
        
        [scene fireBulletFromEntity:self.entity towardsEnemy:self.targetEnemy angle:angle];
        [scene updateHealthBarForEnemy:self.targetEnemy];
    }
    
    if (hc.health <= 0) {
        [self removeEnemy:self.targetEnemy];
    }
}

- (void)attack {
    float angle = 0;
    if (self.heading.x == 1) angle = 90;
    else if (self.heading.x == -1) angle = 270;
    else if (self.heading.y == -1) angle = 180;
    
    Level1Scene *scene = (Level1Scene *)self.sprite.scene;
    if (scene) {
        [scene fireBulletFromEntity:self.entity angle:angle];
    }
}

- (void)enemyInRange:(GKEntity *)enemy {
    [self startAttacking];
//    if (self.targetEnemy != enemy) {
//        self.targetEnemy = enemy;
//        
//        [self startAttackingTargetEnemy];
//    }
}

- (void)removeEnemy:(GKEntity *)enemy {
    int index = 0;
    
    for (GKEntity *e in self.enemiesInRange) {
        if (e == enemy) {
            [self.enemiesInRange removeObjectAtIndex:index];
            
            if (e == self.targetEnemy)
                self.targetEnemy = nil;
            
            break;
        }
        index++;
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
    [self.enemiesInRange addObject:enemy];
}

- (void)enemyExitedTowerRange:(GKEntity *)enemy {
    [self removeEnemy:enemy];
}

@end
