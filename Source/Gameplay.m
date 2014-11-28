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
    NSNumber *_highScore;
}

-(void)didLoadFromCCB{
 
    // how come I dont see this tile?
    _highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
    if (!_highScore){
        _highScore=0;
    }
    
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
    if (_grid.points > [_highScore intValue]) {
        // new highscore!
        _highScore = [NSNumber numberWithInt:(int)_grid.points];
        [[NSUserDefaults standardUserDefaults] setObject:_highScore forKey:@"highscore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_grid.points];
    _highscoreLabel.string = [NSString stringWithFormat:@"%@", _highScore];
}

// wipes the grid
- (void) reset {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
