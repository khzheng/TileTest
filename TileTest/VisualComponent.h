//
//  VisualComponent.h
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import <GameplayKit/GameplayKit.h>
#import <SpriteKit/SpriteKit.h>
#import "Level1Scene.h"

@interface VisualComponent : GKComponent

@property (nonatomic, weak) Level1Scene *scene;
@property (nonatomic, strong) SKSpriteNode *sprite;
@property (nonatomic, assign) vector_int2 coordinate;

- (instancetype)initWithScene:(Level1Scene *)scene
                       sprite:(SKSpriteNode *)sprite
                   coordinate:(vector_int2)coordinate;

@end
