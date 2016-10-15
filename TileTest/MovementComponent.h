//
//  MovementComponent.h
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "VisualComponent.h"

@interface MovementComponent : VisualComponent

@property (nonatomic, assign) vector_int2 destination;

- (instancetype)initWithScene:(Level1Scene *)scene
                       sprite:(SKSpriteNode *)sprite
                   coordinate:(vector_int2)coordinate
                  destination:(vector_int2)destination;
- (NSArray *)pathToDestination;
- (void)followPath:(NSArray *)path;

@end
