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
static const CGFloat SOUND_DELAY = 0.3f;

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
    
    // [tile performSelector:@selector(cleanup)];
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
    int availableRow = [self nextAvailableRow:touchColumn];
    if(availableRow>=0){
        NSLog(@"space available, moving");
        // NSLog(@"spot open in column %d", touchColumn);
 
        // how about copy over the properties or use a cleaner methods
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
        //this is why it hovers from the top
        tile.position = [self positionForColumn:touchColumn row:GRID_SIZE];
        
        // separate way to track references
        [self addChild:tile];
        [self moveTile:tile newX:touchColumn newY:availableRow];
        
        // count all neighbors and blow things up
        // delay .2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self countNeighbors];
            [self updateTiles];
        });
   
    }
    else{
        // NSLog(@"Column Full");
    }
}

-(int)columnForTouchPosition:(CGPoint)touchPosition{
    return touchPosition.x / ( _columnWidth + _tileMarginHorizontal);
}

// given column index, what is next available row slot
// my columns and rows are all screwy
// maybe reverse this, creates unnecessary extra loops
-(int)nextAvailableRow:(int)columnIdx{
    int idx = -1;
    for(int i = GRID_SIZE-1; i >= 0; i--){
        // NSLog(@"%d %d", i, columnIdx);
        // no we counting top down
        // if there isn't a tile, return the next available row slot
        Tile *tile = _gridArray[columnIdx][i];
        if ([tile isEqual:_noTile]) {
            idx = i;
        }
    }
    return idx;
}

// create a point given column row; did some crazy margin edits to make it fit
- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row {
    NSInteger x = _tileMarginHorizontal + column * (_tileMarginHorizontal + _columnWidth);
    NSInteger y = (_tileMarginVertical) + row * (_tileMarginVertical + _columnHeight);
    return CGPointMake(x,y);
}

// move tile to new spot x = row, y = columns??
- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
    // what happened to old position?
    _gridArray[newX][newY] = tile;
    // _gridArray[oldX][oldY] = _noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    NSLog(@"new position %f %f", newPosition.x, newPosition.y);
    
    // do calculation for distance on how far to move
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
    
    // play sound effect
    [self playSound:@"drop.wav"];
}

-(void)playSound:(NSString*)sound{
    [self scheduleBlock:^(CCTimer *timer){
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:sound];
    } delay:SOUND_DELAY];
}

// creates a new tile  ( when is this used? )
-(Tile*)newTile{
    Tile *tile = [[Tile alloc] initTile];
    tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
    // tile.position = [self positionForColumn:touchColumn row:availableRow];
    [self addChild:tile]; // i guess so we can see it
    return tile;
}


// factor this guy something broken with this logic...
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
            if([_gridArray[i][j] isEqual:_noTile]){
                // NSLog(@"catch null");
                continue;
            }
            
            // else
            Tile *currTile = _gridArray[i][j];
            currTile.sameNeighbors = 0;
            
            // fix logic here, check only 4 spots
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
                    // wow this is ugly, XOR != one parameter must be true otherwise false
                    if (!((x == i) && (y == j)) && isIndexValid && ((x==i) != (y==j)))
                    {
                        Tile *neighbor = _gridArray[x][y];
                        if([neighbor isEqual:_noTile]){
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
                
                // what if two blow up at the same time?
                // race condition, needs to land before it disappears
                [self playSound:@"break.wav"];
                [self tileRemoved:currTile];
                _gridArray[i][j] = _noTile;
                
                
                //2. recursively destroy adjacent 3
                
                //1. need to redraw now.. dropping down all tiles.
                // drop everything above by 1
                // create a delay to see what happens for dropping
                // [self performSelector:@selector(dropColumn:) withObject:i withObject:j+1 afterDelay:1.0];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self dropColumn:i row:j+1];
                });
                //[self dropColumn:i row:j+1];
                
                // 3. tile exploding animation?
            }
            
        }
        
    }
}

- (void)tileRemoved:(CCNode *)tile {
    [tile removeFromParent];
}

-(void)dropColumn:(int)column row:(int)row{
    NSLog(@"drop column %d %d", column, row);
    // give column, move all tiles down 1 to next row...
    // which is column and which is row..
    for (int j = row; j < [_gridArray[column] count]; j++)
    {
        // - (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
        Tile *tile = _gridArray[column][j];
        // check if tile exists
        // int availableRow = [self nextAvailableRow:Column];
        if([tile isEqual:_noTile])
        {
            return;
        }
    
        // the redraw is not working for some reason
        int availableRow = [self nextAvailableRow:column];
        NSLog(@"drop to column %d %d", column, availableRow);
        [self moveTile:tile newX:column newY:availableRow];
        _gridArray[column][j] = _noTile;
        
    }
}
@end