//
//  Level1Scene.m
//  TileTest
//
//  Created by Ken Zheng on 10/6/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "Level1Scene.h"
#import "Tower.h"
#import "Enemy.h"
#import <GameplayKit/GameplayKit.h>

@interface Level1Scene()

@property (nonatomic, strong) SKTileMapNode *road;
@property (nonatomic, strong) SKTileMapNode *grass;

@property (nonatomic, strong) GKGridGraph *graph;
@property (nonatomic, strong) GKGridGraphNode *spawnNode;
@property (nonatomic, strong) GKGridGraphNode *endNode;
@property (nonatomic, strong) NSMutableArray *towers;
@property (nonatomic, strong) NSMutableArray *enemies;

@end

@implementation Level1Scene

- (void)didMoveToView:(SKView *)view {
    // load scene nodes
    self.road = (SKTileMapNode *)[self childNodeWithName:@"road"];
    self.grass = (SKTileMapNode *)[self childNodeWithName:@"grass"];
    
    // create graph
    self.graph = [GKGridGraph graphFromGridStartingAt:(vector_int2){0, 0} width:(int)self.road.numberOfColumns height:(int)self.road.numberOfRows diagonalsAllowed:NO];
    
    // find walls
    NSMutableArray *walls = [NSMutableArray array];
    for (int col = 0; col < self.road.numberOfColumns; col++) {
        for (int row = 0; row < self.road.numberOfRows; row++) {
            SKTileDefinition *tileDef = [self.road tileDefinitionAtColumn:col row:row];
            if (tileDef == nil) {
                [walls addObject:[self.graph nodeAtGridPosition:(vector_int2){col, row}]];
            }
        }
    }
    
    // remove walls
    [self.graph removeNodes:walls];
    
    self.spawnNode = [self.graph nodeAtGridPosition:(vector_int2){5,15}];
    self.endNode = [self.graph nodeAtGridPosition:(vector_int2){20,5}];
    
    self.towers = [NSMutableArray array];
    
    [self drawGrid];
    
    // schedule enemies
    self.enemies = [NSMutableArray array];
    [self performSelector:@selector(addAndMoveEnemy) withObject:nil afterDelay:2];
    [self performSelector:@selector(addAndMoveEnemy) withObject:nil afterDelay:4];
    [self performSelector:@selector(addAndMoveEnemy) withObject:nil afterDelay:6];
    [self performSelector:@selector(addAndMoveEnemy) withObject:nil afterDelay:8];
}

- (void)addAndMoveEnemy {
    Enemy *enemy = [Enemy nodeWithScene:self position:[self positionForTileCoordinate:CGPointMake(5, 15)]];
    [self addChild:enemy];
    [self.enemies addObject:enemy];
    
    NSArray *pathNodes = [self.graph findPathFromNode:self.spawnNode toNode:self.endNode];
    NSMutableArray *moveActions = [NSMutableArray array];
    
    for (int i = 1; i < [pathNodes count]; i++) {
        GKGridGraphNode *node = pathNodes[i];
        CGPoint destination = [self positionForTileCoordinate:CGPointMake(node.gridPosition.x, node.gridPosition.y)];
        SKAction *moveAction = [SKAction moveTo:destination duration:0.5];
        [moveActions addObject:moveAction];
    }
    
    SKAction *sequence = [SKAction sequence:moveActions];
    
    [enemy.sprite runAction:sequence];
}

- (CGPoint)positionForTileCoordinate:(CGPoint)coordinate {
    CGSize tileSize = self.road.tileSize;
    return CGPointMake(coordinate.x * tileSize.width + tileSize.width / 2, coordinate.y * tileSize.height + tileSize.height / 2);
}

- (CGPoint)tileCoordinateForPosition:(CGPoint)position {
    return CGPointMake([self.road tileColumnIndexFromPosition:position], [self.road tileRowIndexFromPosition:position]);
}

- (void)drawGrid {
    CGSize tileSize = self.road.tileSize;
    CGSize mapSize = self.road.mapSize;
    
    // draw horizontal lines
    for (int y = 0; y < mapSize.height; y++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(mapSize.width, 2)];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(0, tileSize.height * y);
        [self addChild:line];
    }
    
    // draw vertical lines
    for (int x = 0; x < mapSize.width; x++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(2, mapSize.height)];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(tileSize.width * x, 0);
        [self addChild:line];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint tilePosition = [self tileCoordinateForPosition:touchLocation];
    
    // is the tile eligible for a tower?
    SKTileDefinition *tileDef = [self.grass tileDefinitionAtColumn:tilePosition.x row:tilePosition.y];
    if (tileDef) {
        // is there a tower at the touch location
        BOOL shouldPlaceTower = YES;
        for (Tower *tower in self.towers) {
            if (CGRectContainsPoint(tower.sprite.frame, touchLocation)) {
                shouldPlaceTower = NO;
                break;
            }
        }
        
        if (shouldPlaceTower) {
            Tower *tower = [Tower nodeWithScene:self position:[self positionForTileCoordinate:[self tileCoordinateForPosition:touchLocation]]];
            
            [self addChild:tower];
            [self.towers addObject:tower];
        } else {
            NSLog(@"tower already exists at %@", NSStringFromCGPoint([self tileCoordinateForPosition:touchLocation]));
        }
    } else {
        NSLog(@"cannot place tower here");
    }
}

@end
