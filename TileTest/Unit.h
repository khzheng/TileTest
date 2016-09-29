//
//  Unit.h
//  TileTest
//
//  Created by Ken Zheng on 9/28/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface Unit : SKNode

@property (nonatomic, weak) GameScene *gameScene;
@property (nonatomic, strong) SKSpriteNode *sprite;
@property (nonatomic, strong) SKLabelNode *hpLabel;
@property (nonatomic, assign) NSInteger hp;
@property (nonatomic, assign) NSInteger movementRange;
@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, assign) BOOL selectingMovement;

+ (instancetype)nodeWithScene:(GameScene *)gameScene position:(CGPoint)position;

- (void)selectUnit;
- (void)deselectUnit;

@end
