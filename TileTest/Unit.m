//
//  Unit.m
//  TileTest
//
//  Created by Ken Zheng on 9/28/16.
//  Copyright © 2016 Ken Zheng. All rights reserved.
//

#import "Unit.h"

@implementation Unit

+ (instancetype)unitAtPosition:(CGPoint)position {
    Unit *unit = [[Unit alloc] init];
    unit.sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Soldier"];
    unit.sprite.position = position;
    [unit addChild:unit.sprite];
    
    unit.hpLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    unit.hpLabel.text = [NSString stringWithFormat:@"%ld", (long)unit.hp];
    unit.hpLabel.fontSize = 24;
    unit.hpLabel.fontColor = [SKColor blackColor];
    unit.hpLabel.position = CGPointMake(unit.sprite.frame.size.width - unit.hpLabel.frame.size.width - 8, -unit.hpLabel.frame.size.height - 8);
    [unit.sprite addChild:unit.hpLabel];
    
    return unit;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hp = 10;
        _movementRange = 3;
        _isMoving = NO;
        _selectingMovement = NO;
    }
    
    return self;
}

@end
