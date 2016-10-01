//
//  TileData.m
//  TileTest
//
//  Created by Ken Zheng on 10/1/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "TileData.h"

@implementation TileData

- (instancetype)init {
    self = [super init];
    if (self) {
        _movementCost = 1;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TileData { position: %@, type: %@, movementCost: %d }", NSStringFromCGPoint(self.tilePosition), self.tileType, self.movementCost];
}

@end
