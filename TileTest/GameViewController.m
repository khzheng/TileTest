//
//  GameViewController.m
//  TileTest
//
//  Created by Ken Zheng on 9/20/16.
//  Copyright (c) 2016 Ken Zheng. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "Level1Scene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    Level1Scene *scene1 = [Level1Scene nodeWithFileNamed:@"Level1"];
    scene1.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene1];
    
    // Create and configure the scene.
//    GameScene *scene = [GameScene nodeWithFileNamed:@"Level1"];
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//
//    // Present the scene.
//    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
