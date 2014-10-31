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
    _nextTile = [[Tile alloc] initTile];
    _nextTile.position = ccp(25, 400);
    [self addChild:_nextTile];
}

// every second of update I could redraw the next tile?


@end
