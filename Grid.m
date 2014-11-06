//
//  Grid.m
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Grid.h"


@implementation Grid {
	CGFloat _columnWidth;
	CGFloat _columnHeight;
	CGFloat _tileMarginVertical;
	CGFloat _tileMarginHorizontal;
    
    NSMutableArray *_gridArray;
	NSNull *_noTile;

}

static const NSInteger GRID_SIZE = 6;
static const NSInteger GRID_ROWS = GRID_SIZE;
static const NSInteger GRID_COLUMNS = GRID_SIZE;

- (void)didLoadFromCCB {
    
    _noTile = [NSNull null];
	
    // draws brown squares
    [self setupBackground];
	[self nullGrid];
    
    self.userInteractionEnabled = TRUE;
    
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"drop.wav"];
    
    self.nextTile = [[Tile alloc] initTile];
    
}

-(void) nullGrid{
    // cleans objects in array
    _gridArray = [NSMutableArray array];
    for (int i = 0; i < GRID_SIZE; i++) {
		_gridArray[i] = [NSMutableArray array];
		for (int j = 0; j < GRID_SIZE; j++) {
			_gridArray[i][j] = _noTile;
		}
	}
    // need to trigger a redraw
}

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
    
    // grid is off for calculation
	for (int i = 0; i < GRID_SIZE; i++) {
		// iterate through each row
		x = _tileMarginHorizontal;
		for (int j = 0; j < GRID_SIZE; j++) {
			//  iterate through each column in the current row
            // add grid
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor brownColor]];
			backgroundTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
			backgroundTile.position = ccp(x, y);
			[self addChild:backgroundTile]; // color node
            // [self addChild:tile]; // tile class
			x+= _columnWidth + _tileMarginHorizontal;
		}
		y += _columnHeight + _tileMarginVertical;
	}
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //get the x,y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];

    // make a move
    int touchColumn = [self columnForTouchPosition:touchLocation];
    // NSLog(@"touch Column %d", touchColumn);
    
    // returns an idx
    int availableRow = [self nextAvailableRow:touchColumn];
    if(availableRow>=0){
        // NSLog(@"spot open in column %d", touchColumn);
        // drop a tile in the spot
        // create a tile and move to newX newY
        
        // self.nextTile -- update the image
        /**
         copy the parameters of the tile class...maybe make a method
         
         then another method to re instantiate! copy - then a recreate
         
        **/
        
        // how about copy over the properties
        Tile *tile = [[Tile alloc] initTile];
        
        tile.filename = self.nextTile.filename;
        tile.tileType = self.nextTile.tileType;
        [tile setTexture:[[CCSprite spriteWithImageNamed:tile.filename]texture]];
        
        // set texture
        
        // copy properties of self.nextTile;
        
        [self.nextTile randomProperties];
        
        
        // Tile *tile = self.nextTile;
        tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
        
        // position called again in moveTile
        tile.position = [self positionForColumn:touchColumn row:GRID_SIZE];
        
        // separate way to track references
        [self addChild:tile];
        [self moveTile:tile newX:touchColumn newY:availableRow];
        
        // count neighbors and blow things up
        [self countNeighbors];
        [self updateTiles];
    }
    else{
        // NSLog(@"Column Full");
    }
    //get the Creature at that location
    // Tile *tile = [self tileForTouchPosition:touchLocation];
    // tile.isActive = !tile.isActive;
}

-(int)columnForTouchPosition:(CGPoint)touchPosition{
    return touchPosition.x / ( _columnWidth + _tileMarginHorizontal);
}

// given column index, what is next available row slot
// my columns and rows are all screwy
-(int)nextAvailableRow:(int)columnIdx{
    for(int i = 0; i < GRID_SIZE; i++){
        
        // if there isn't a tile, return the next available row slot
        Tile *tile = _gridArray[columnIdx][i];
        if ([tile isEqual:_noTile]) {
            return i;
        }
    }
    return -1;
}

// move tile to new spot x = row, y = columns??
- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
    _gridArray[newX][newY] = tile;
    // _gridArray[oldX][oldY] = _noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    
    // do calculation for distance on how far to move
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
    
    
    // play sound effect
    
    // - (CCTimer *)scheduleOnce:(SEL)selector delay:(CCTime)delay
    // [self scheduleOnce: @selector(playDropSound) delay:0.3f];
    [self scheduleBlock:^(CCTimer *timer){
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"drop.wav"];
    } delay:0.3f];
}

// well i guess i dont need this guy anymore
-(void)playDropSound{
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"drop.wav"];
}

-(Tile*)newTile{
    Tile *tile = [[Tile alloc] initTile];
    tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
    // tile.position = [self positionForColumn:touchColumn row:availableRow];
    [self addChild:tile]; // i guess so we can see it
    return tile;
}

// create a point given column row; did some crazy margin edits to make it fit
- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row {
	NSInteger x = _tileMarginHorizontal + column * (_tileMarginHorizontal + _columnWidth);
	NSInteger y = (_tileMarginVertical) + row * (_tileMarginVertical + _columnHeight);
	return CGPointMake(x,y);
}

// factor this guy
-(void) countNeighbors{
    // iterate through the rows
    // note that NSArray has a method 'count' that will return the number of elements in the array
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            // access the creature in the cell that corresponds to the current row/column
            
            // tiles is not made yet?
            if(_gridArray[i][j] == _noTile){
                // NSLog(@"catch null");
                continue;
            }
            // else
            Tile *currTile = _gridArray[i][j];
            
            currTile.sameNeighbors = 0;
            
            // now examine every cell around the current one
            // go through the row on top of the current cell, the row the cell is in, and the row past the current cell
            for (int x = (i-1); x <= (i+1); x++)
            {
                // go through the column to the left of the current cell, the column the cell is in, and the column to the right of the current cell
                for (int y = (j-1); y <= (j+1); y++)
                {
                    // check that the cell we're checking isn't off the screen
                    BOOL isIndexValid;
                    isIndexValid = [self isIndexValidForX:x andY:y];
                    
                    // skip over all cells that are off screen AND the cell that contains the creature we are currently updating
                    if (!((x == i) && (y == j)) && isIndexValid)
                    {
                        Tile *neighbor = _gridArray[x][y];
                        if(neighbor == (Tile*)_noTile){
                            continue;
                        }
                        if (neighbor.filename == currTile.filename)
                        {
                            currTile.sameNeighbors += 1;
                        }
                    }
                }
            }
        }
    }
}

// taken from makes games with us game of life
- (BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = YES;
    if(x < 0 || y < 0 || x >= GRID_ROWS || y >= GRID_COLUMNS)
    {
        isIndexValid = NO;
    }
    return isIndexValid;
}

-(void) updateTiles{
    // iterate over all tiles and blow up 4 of a kind.
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            if([_gridArray[i][j] isEqual:_noTile]){
                // NSLog(@"catch null");
                continue;
            }
            Tile *currTile = _gridArray[i][j];
            
            // flagging 2 would be 3?
            if(currTile.sameNeighbors >= 2)
            {
                // blow them up .. how do i...
                // currTile = (Tile*)_noTile; // set it to null...
                NSLog(@"got 3");
                [self tileRemoved:currTile];
                _gridArray[i][j] = _noTile;
                
                // recursively destroy adjacent 3
                
                // need to redraw now.. dropping down all tiles.
                //[self moveDropColumn:column];
            }
            
        }
        
    }
}

- (void)tileRemoved:(CCNode *)tile {
    [tile removeFromParent];
}

-(void)dropColumn:(NSInteger)column{
    // give column, move all tiles down 1 to next row...
}
@end