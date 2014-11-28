//
//  Gameplay.m
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Grid.h"
#import "Tile.h"


@implementation Gameplay {
    Grid *_grid;
    Tile *_nextTile;
    CCButton *_gameoverButton;
    CCLabelTTF  *_scoreLabel;
    CCLabelTTF  *_highscoreLabel;
    BOOL *_gameover;
}

-(void)didLoadFromCCB{
 
    // how come I dont see this tile?
    _gameover=FALSE;
    _nextTile = _grid.nextTile;
    _nextTile.position = ccp(5, 450);
    [self addChild:_nextTile];
}

// every second of update I could redraw the next tile?
- (void)update:(CCTime)delta {
    // update the texture of _nextTile if it changes!
    [_nextTile setTexture:[[CCSprite spriteWithImageNamed:_grid.nextTile.filename]texture]];
    
    if(_grid.gameOver){
        _gameoverButton.visible=YES;
    }
    
    /**
     if(_paused)
     {
     [[CCDirector sharedDirector] pause];
     [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
     }
     else
     {
     [[CCDirector sharedDirector] resume];
     [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
     }
     **/
    
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_grid.points];
}

// wipes the grid
- (void) reset {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
