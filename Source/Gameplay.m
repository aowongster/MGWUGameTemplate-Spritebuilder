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
}

-(void)didLoadFromCCB{
 
    // how come I dont see this tile?
    _nextTile = _grid.nextTile;
    _nextTile.position = ccp(25, 400);
    [self addChild:_nextTile];
}

// every second of update I could redraw the next tile?
- (void)update:(CCTime)delta {
    // update the texture of _nextTile if it changes!
    [_nextTile setTexture:[[CCSprite spriteWithImageNamed:_grid.nextTile.filename]texture]];
    // [yourSprite setTexture:[[CCSprite spriteWithFile:@"yourImage.png"]texture]];
}

@end
