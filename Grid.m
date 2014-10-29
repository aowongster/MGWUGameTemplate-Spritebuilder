//
//  Grid.m
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Tile.h"


@implementation Grid {
	CGFloat _columnWidth;
	CGFloat _columnHeight;
	CGFloat _tileMarginVertical;
	CGFloat _tileMarginHorizontal;
    
    NSMutableArray *_gridArray;
	NSNull *_noTile;
}
static const NSInteger GRID_SIZE = 6;


static const NSInteger START_TILES = 2;

// put logic in here
- (void)setupBackground
{
	// load one tile to read the dimensions
	CCNode *tile = [CCBReader load:@"backgroundTile"];
    
    // these guys are fixed, reports 0 // hard code not scalable
	_columnWidth = tile.contentSize.width;
	_columnHeight = tile.contentSize.height;
    
    // this hotfix is needed because of issue #638 in Cocos2D 3.1 / SB 1.1 (https://github.com/spritebuilder/SpriteBuilder/issues/638)
    
    [tile performSelector:@selector(cleanup)];
	// calculate the margin by subtracting the tile sizes from the grid size
	_tileMarginHorizontal = (self.contentSize.width - (GRID_SIZE * _columnWidth)) / (GRID_SIZE+1);
	_tileMarginVertical = (self.contentSize.height - (GRID_SIZE * _columnWidth)) / (GRID_SIZE+1);
	// set up initial x and y positions
	float x = _tileMarginHorizontal;
	float y = _tileMarginVertical;
    
    
    _gridArray = [NSMutableArray array];
    // grid is off for calculation
	for (int i = 0; i < GRID_SIZE; i++) {
		// iterate through each row
		x = _tileMarginHorizontal;
        _gridArray[i] = [NSMutableArray array];
		for (int j = 0; j < GRID_SIZE; j++) {
			//  iterate through each column in the current row
            
            // add sprite.
            // add in a tile?
            Tile *tile = [[Tile alloc] initTile];
            tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
            tile.position = ccp(x, y);
            
            // add grid
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor brownColor]];
			backgroundTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
			backgroundTile.position = ccp(x, y);
           
			
            
			[self addChild:backgroundTile]; // color node
            [self addChild:tile]; // tile class
            _gridArray[i][j] = tile;
            
            

			x+= _columnWidth + _tileMarginHorizontal;
		}
		y += _columnHeight + _tileMarginVertical;
	}
}

- (void)didLoadFromCCB {
	[self setupBackground];
    self.userInteractionEnabled = TRUE;
   
}
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    
    //get the x,y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    NSLog(@"%f %f", touchLocation.x, touchLocation.y);
    //get the Creature at that location
    Tile *tile = [self tileForTouchPosition:touchLocation];
    tile.isActive = !tile.isActive;
}

-(Tile*) tileForTouchPosition: (CGPoint)touchPosition {
    // we have a problem because of ... horizontal and vertical margins?!
    int row = touchPosition.y/ (_columnHeight + _tileMarginVertical);
    int column = touchPosition.x/ (_columnWidth + _tileMarginHorizontal);
    
    NSLog(@"%d %d", row, column);
    
    return _gridArray[row][column];
}

@end