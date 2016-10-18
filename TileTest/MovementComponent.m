//
//  MovementComponent.m
//  TileTest
//
//  Created by Ken Zheng on 10/15/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "MovementComponent.h"

@implementation MovementComponent

- (instancetype)initWithScene:(Level1Scene *)scene
                       sprite:(SKNode *)sprite
                   coordinate:(vector_int2)coordinate
                  destination:(vector_int2)destination {
    self = [super initWithScene:scene sprite:sprite bulletSprite:nil coordinate:coordinate];
    if (self) {
        _destination = destination;
    }
    
    return self;
}

- (NSArray *)pathToDestination {
    GKGridGraphNode *currentNode = [self.scene.graph nodeAtGridPosition:self.coordinate];
    GKGridGraphNode *destinationNode = [self.scene.graph nodeAtGridPosition:self.destination];
    
    return [self.scene.graph findPathFromNode:currentNode toNode:destinationNode];
}

- (void)followPath:(NSArray *)path {
    NSMutableArray *sequence = [NSMutableArray array];
    
    for (GKGridGraphNode *node in path) {
        SKAction *moveAction = [SKAction moveTo:[self.scene positionForTileCoordinate:CGPointMake(node.gridPosition.x, node.gridPosition.y)] duration:0.5];
        SKAction *updateAction = [SKAction runBlock:^{
            self.coordinate = node.gridPosition;
        }];
        
        [sequence addObjectsFromArray:@[moveAction, updateAction]];
    }
    
    [self.sprite runAction:[SKAction sequence:sequence] completion:^{
        [self.scene removeEnemy:self.entity];
    }];
}

@end
