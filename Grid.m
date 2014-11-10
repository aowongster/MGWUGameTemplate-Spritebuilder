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

static const NSInteger NUM_ROWS = 9;
static const NSInteger NUM_COLUMNS = 6;
static const NSInteger TILE_SIZE = 45;

static const CGFloat ANIMATION_DELAY = 0.25f;
static const CGFloat SOUND_DELAY = ANIMATION_DELAY + 0.1f;
static const CGFloat UPDATE_DELAY = ANIMATION_DELAY + 0.1f;
static const CGFloat DROP_DELAY = ANIMATION_DELAY/3.0f;

// x 320 x 554

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

// instantiates _gridArray[column][row]
-(void) nullGrid{
    _gridArray = [NSMutableArray array];
    for (int i = 0; i < NUM_COLUMNS; i++) {
		_gridArray[i] = [NSMutableArray array];
		for (int j = 0; j < NUM_ROWS; j++) {
			_gridArray[i][j] = _noTile;
		}
	}
}

- (void)setupBackground
{
    _columnWidth = TILE_SIZE;
    _columnHeight = TILE_SIZE;
    
    // this hotfix is needed because of issue #638 in Cocos2D 3.1 / SB 1.1 (https://github.com/spritebuilder/SpriteBuilder/issues/638)
    
    // [tile performSelector:@selector(cleanup)];
	// calculate the margin by subtracting the tile sizes from the grid size
	_tileMarginHorizontal = (self.contentSize.width - (NUM_COLUMNS * TILE_SIZE)) / (NUM_COLUMNS+1);
	_tileMarginVertical = (self.contentSize.height - (NUM_ROWS * TILE_SIZE)) / (NUM_ROWS+1);
	// set up initial x and y positions
	float x = _tileMarginHorizontal;
	float y = _tileMarginVertical;
    //NSLog(@"content size: %f %f", self.contentSize.height, self.contentSize.height);
    //NSLog(@"%f %f", x, y);
    
    // let to right, bottom to top
	for (int i = 0; i < NUM_ROWS; i++) {
		// iterate through each row
		x = _tileMarginHorizontal;
		for (int j = 0; j < NUM_COLUMNS; j++) {
			//  iterate through each column in the current row
            // add grid
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor brownColor]];
			backgroundTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
			backgroundTile.position = ccp(x, y);
			[self addChild:backgroundTile]; // color node
            
            // my adding is a bit funky
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
    //NSLog(@"touch Column %d", touchColumn);
    int availableRow = [self nextAvailableRow:touchColumn];
    if(availableRow>=0){
        // NSLog(@"space available, moving");
        // NSLog(@"spot open in column %d", touchColumn);
 
        // how about copy over the properties or use a cleaner methods
             // copy properties of self.nextTile;
        Tile *tile = [[Tile alloc] initTile];
        tile.filename = self.nextTile.filename;
        tile.tileType = self.nextTile.tileType;
        //tile.row = NUM_ROWS;
        [tile setTexture:[[CCSprite spriteWithImageNamed:tile.filename]texture]];
        
        // new nextTile
        [self.nextTile randomProperties];
        
        // starting position of tile
        tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
        tile.position = [self positionForColumn:touchColumn row:NUM_ROWS];
        [self addChild:tile];
        
        [self moveTile:tile newX:touchColumn newY:availableRow];
    
        
        // count all neighbors and blow things up
        // delay .2 seconds
        // why do we need this?
      
        // wont update until first move
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPDATE_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self countNeighbors];
            [self updateTiles];
        });
      
        // TILE FALLS BEFORE COLUMN CAN BE DROPPED
   
    }
}

-(int)columnForTouchPosition:(CGPoint)touchPosition{
    return touchPosition.x / ( _columnWidth + _tileMarginHorizontal);
}

// given column index, what is next available row slot
// maybe reverse this, creates unnecessary extra loops
-(int)nextAvailableRow:(int)columnIdx{
    for(int i = 0; i<NUM_ROWS; i++){
        // NSLog(@"%d %d", i, columnIdx);
        // no we counting top down
        // if there isn't a tile, return the next available row slot
        Tile *tile = _gridArray[columnIdx][i];
        if ([tile isEqual:_noTile]) {
            return i;
        }
    }
    return -1;
}

// create a point given column row; did some crazy margin edits to make it fit
- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row {
    NSInteger x = _tileMarginHorizontal + column * (_tileMarginHorizontal + _columnWidth);
    NSInteger y = (_tileMarginVertical) + row * (_tileMarginVertical + _columnHeight);
    return CGPointMake(x,y);
}

// move tile to new spot x = row, y = columns??
// this is the heart, when next spot is determined, there's a race condition
- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY delay:(CGFloat)delay {
    // what happened to old position?
    _gridArray[newX][newY] = tile;
    tile.column = newX;
    tile.row = newY;
    // _gridArray[oldX][oldY] = _noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    NSLog(@"new position %f %f", newPosition.x, newPosition.y);
    
    // do calculation for distance on how far to move
    // better heuristic would be by distance! longer distance = more time
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:delay position:newPosition];
    [tile runAction:moveTo];
    
    // play sound effect
    [self playSound:@"drop.wav"];
    
}

- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
    [self moveTile:tile newX:newX newY:newY delay:ANIMATION_DELAY];
}


// bug here
-(void)dropColumn:(int)column row:(int)row{
    // NSLog(@"drop column %d %d", column, row);
    // give column, move all tiles down 1 to next row...
    // is there someting about the timing code that messes thisup?
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPDATE_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
            // int availableRow = [self nextAvailableRow:column];
            //NSLog(@"drop to column %d %d", column, availableRow);
            // kinda buggy... move tile should have A to B
            
            // can i just drop down 1? j -1 hit a zero
            int nextRow = [self nextAvailableRow:column];
            [self moveTile:tile newX:column newY:nextRow delay:DROP_DELAY]; // this assumes nothing is at the moved spot
            _gridArray[column][j] = _noTile;
            
            
        }
        [self playSound:@"drop.wav"];
        
    });
}

// factor this guy something broken with this logic...
// this guy still buggy, fix to count 4's maybe need different algo
-(void) countNeighbors{
    // iterate through the rows
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            if([_gridArray[i][j] isEqual:_noTile]){
                // NSLog(@"catch null");
                continue;
            }
            
            // else
            Tile *currTile = _gridArray[i][j];
            // need to zero out
            //currTile.neighborArray = 0
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
                        if (currTile.filename == neighbor.filename)
                        {
                            // [nsMutArray insertObject:label atIndex:0];
                            // [currTile.neighborArray insertObject:neighbor atIndex:currTile.sameNeighbors]; // keeps adding to front
                            currTile.neighborArray[currTile.sameNeighbors] = neighbor;
                            //NSLog(@"neighbor obj idx add count: %d", currTile.sameNeighbors);
                            currTile.sameNeighbors += 1;
                        }
                    }
                }
            }
            // out of the check
            if(currTile.sameNeighbors >= 2)
            {
                currTile.remove = YES;
            }
            else{
                currTile.remove = NO;
            }
            
        }
    }
}



// need to update logic to find match 3s
// recursively calls itsself?
-(void) updateTiles{
    // iterate over all tiles and blow up 3 of a kind.
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            if([_gridArray[i][j] isEqual:_noTile]){
                // NSLog(@"catch null");
                continue;
            }
            
            // potentially blowup marked tiles here
            Tile *currTile = _gridArray[i][j];
            
            // flagging 2 would be 3?
            // have an array... blow up all neighbors
            if([currTile.neighborArray count] >= 2)
            {
                // blow them up .. how do i...
                // NSLog(@"neighbors: %ld",[currTile.neighborArray count]);
                // what if two blow up at the same time?
                [self tileRemoved:currTile];
                [self playSound:@"break.wav"];
             
                [self dropColumn:i row:j+1];
                // _gridArray[i][j] = _noTile;
                //2. recursively destroy adjacent 3
                [self killNeighbors:currTile];
            }
        }
        
    }
    // run a sweeping mass kill all the same time instead of in the loops?
}

// give tile remove its neighbors
-(void) killNeighbors:(Tile*)tile{
    for(int i =0; i< [tile.neighborArray count];i++)
    {
        // delete all neighbors + drop their columns
        Tile* neighborTile = tile.neighborArray[i];
        if(![neighborTile isEqual:_noTile])
        {
            
            [self tileRemoved:neighborTile];
            [self dropColumn:neighborTile.column row:neighborTile.row+1];
            
            // need to remove their grid position as well
            // comboes are not workin
        }
        
    }
}

// effect and removal from parent
// popping is happening before the Drop! ** FIX
- (void)tileRemoved:(Tile *)tile {
    _gridArray[tile.column][tile.row] = _noTile;
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"TileBreak"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = CGPointMake(tile.position.x + _columnWidth/2, tile.position.y + _columnHeight/2);
    [tile.parent addChild:explosion];
    [tile removeFromParent];
    
}

-(void)playSound:(NSString*)sound{
    [self scheduleBlock:^(CCTimer *timer){
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:sound];
    } delay:SOUND_DELAY];
}

// taken from makes games with us game of life
- (BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = YES;
    if(x < 0 || y < 0 || x >= NUM_COLUMNS|| y >= NUM_ROWS)
    {
        isIndexValid = NO;
    }
    return isIndexValid;
}

// creates a new tile  ( when is this used? )
-(Tile*)newTile{
    Tile *tile = [[Tile alloc] initTile];
    tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
    // tile.position = [self positionForColumn:touchColumn row:availableRow];
    [self addChild:tile]; // i guess so we can see it
    return tile;
}


@end