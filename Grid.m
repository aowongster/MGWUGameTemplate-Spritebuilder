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
    NSMutableArray *_dropColumns;
	NSNull *_noTile;
    BOOL _brokeTile;
    int _numBreaks;
    dispatch_queue_t _queue;

}

static const NSInteger NUM_ROWS = 9;
static const NSInteger NUM_COLUMNS = 6;
static const NSInteger TILE_SIZE = 45;

static const CGFloat ANIMATION_DELAY = 0.25f;
static const CGFloat SOUND_DELAY = ANIMATION_DELAY + 0.1f;
static const CGFloat UPDATE_DELAY = ANIMATION_DELAY + 0.2f;

// x 320 x 554

- (void)onEnter {
    [super onEnter];
    
    self.userInteractionEnabled = TRUE;
}

- (void)didLoadFromCCB {
    
    _noTile = [NSNull null];
    _dropColumns = [NSMutableArray array]; // [myIntegers addObject:[NSNumber numberWithInteger:i]];
    
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
    // draws brown squares
    [self setupBackground];
	[self nullGrid];
        
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"drop.wav"];
    
    self.nextTile = [[Tile alloc] initTile];
    
    // fix addBottomRow
    [self addBottomRow];
    [self addBottomRow]; // not drawn
    // [self updateTiles]; // bug in update tiles
    
    NSLog(@"loading grid CCB");
    
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
 
        
        // and its back!
        //Tile *tile = [self newTile:touchColumn row:NUM_ROWS];
        Tile *tile = [self getNextTile:touchColumn row:NUM_ROWS];
        [self moveTile:tile newX:touchColumn newY:availableRow];
        
        
        
        [self playSound:@"drop.wav"];
        
        // maybe put this in update loop !! hmmmm
        _numBreaks = 0;
        _brokeTile = NO;
        do{
            // instant pop before drop animation completes
        
            [self updateTiles];
            
            /**
            [self scheduleBlock:^(CCTimer *timer){
                [self countNeighbors];
                [self updateTiles];
            } delay: _numBreaks * UPDATE_DELAY];
            **/
            
            /**
            dispatch_sync(_queue, ^{
                [self scheduleBlock:^(CCTimer *timer){
                [self countNeighbors];
                [self updateTiles];
                    
                    } delay: UPDATE_DELAY];
            });
            **/
            
            /**
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPDATE_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self countNeighbors];
                [self updateTiles];
            });
             **/
            NSLog(@"finished update");
        }while(_brokeTile);
    }
    
    // check gameOver and freeze game
    if([self isGameOver]){
        // pause
        self.gameOver = YES;
        /**
        [[CCDirector sharedDirector] pause];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        **/
         // show button
    }
}

// need to update logic to find match 3s
// recursively calls itsself?
-(void) updateTiles{
    // iterate over all tiles and blow up 3 of a kind.
    // better more flexible way to iterate... vs hard code
    [self countNeighbors];
    _brokeTile = NO;
    NSLog(@"starting update");
    for (int i = 0; i < [_gridArray count]; i++)
    {
        // iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++)
        {
            Tile *currTile = _gridArray[i][j];
            if([currTile isEqual:_noTile]){
                // NSLog(@"catch null");
                continue;
            }
            
            // add column to drop columns array
            if(currTile.remove){
                [_dropColumns insertObject:[NSNumber numberWithInteger:currTile.column] atIndex:0];
                NSLog(@"adding drop column %ld", currTile.column);
                
                // have a delay before removing?
                [self removeTile:currTile];
                _brokeTile = YES;
                
            }
        }
        
    }
    
    // run a sweeping mass kill all the same time instead of in the loops?
    BOOL columnDropped = NO;
    //NSLog(@"size of dropcolumns: %d", [_dropColumns count]);
    NSMutableArray *discardColumns = [NSMutableArray array];
    NSNumber *column;
    for(column in _dropColumns){
        columnDropped = YES;
        [discardColumns addObject:column];
        [self dropColumn:(int)[column integerValue]];
    }
    [_dropColumns removeObjectsInArray:discardColumns];
 
    if(columnDropped){
        //[self playSound:@"drop.wav"]; // only if something is above it
    }
    
    if(_brokeTile){
        _numBreaks++;
        [self playSound:@"break.wav"];
    }
    
}

// move tile to new spot x = row, y = columns??
- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY delay:(CGFloat)delay {
    _gridArray[newX][newY] = tile;
    tile.column = newX;
    tile.row = newY;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    // NSLog(@"tile: %d %d ,new position %f %f", newX, newY,newPosition.x, newPosition.y);
    
    // do calculation for distance on how far to move
    // better heuristic would be by distance! longer distance = more time
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:delay position:newPosition];
    [tile runAction:moveTo];
    
}

- (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
    [self moveTile:tile newX:newX newY:newY delay:ANIMATION_DELAY];
}


// let's overload without a row..
-(void)dropColumn:(int)column {
    [self dropColumn:column row:0];
}

// FIX drop column image logic is off.
-(void)dropColumn:(int)column row:(int)row{
    
        int nextRow = [self nextAvailableRow:column];
        if(nextRow ==-1){
            return;
        }
        for (int j = nextRow+1; j < NUM_ROWS; j++)
        {
            Tile *tile = _gridArray[column][j];
            if([tile isEqual:_noTile])
            {
                // now we scanning them all
                continue;
            }
            
            //tile exists: index is valid and empty)
            // could go out of bounds here
          
            int nextRowNow = [self nextAvailableRow:column];
            
            // not checking valid index?
      
            _gridArray[column][nextRowNow] = tile;
            tile.column = column;
            tile.row = nextRowNow;
            _gridArray[column][j] = _noTile;
            
            [self scheduleBlock:^(CCTimer *timer){
                CGPoint newPosition = [self positionForColumn:column row:nextRowNow];
                CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:ANIMATION_DELAY position:newPosition];
                [tile runAction:moveTo];
            }delay: UPDATE_DELAY + UPDATE_DELAY*_numBreaks];
            
            
    
            
        }
  
}

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
                            currTile.neighborArray[currTile.sameNeighbors] = neighbor;
                            currTile.sameNeighbors += 1;
                        }
                    }
                }
            }
            // out of the check
            
            // bug with neighbor removal...
            if(currTile.sameNeighbors >= 2)
            {
                // mark neighbors here // I think this works with 4!
                currTile.remove = YES;
                // for (id myArrayElement in myArray)
                for (Tile *neighborTile in currTile.neighborArray){
                    [self removeNeighbors:neighborTile];
                }
                [self removeNeighbors:currTile];
                // and remove neighbors of neighbors!
                // XXX
            }
            
        }
    }
}





// effect and removal from parent
// popping is happening before the Drop! ** FIX
- (void)removeTile:(Tile *)tile {
    _gridArray[tile.column][tile.row] = _noTile;
    
    [self scheduleBlock:^(CCTimer *timer){
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"TileBreak"];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = CGPointMake(tile.position.x + _columnWidth/2, tile.position.y + _columnHeight/2);
        [tile.parent addChild:explosion];
        [tile removeFromParent];
    } delay:UPDATE_DELAY + UPDATE_DELAY*_numBreaks];
    
}

// give tile remove its neighbors
-(void) removeNeighbors:(Tile*)tile{
    for(int i =0; i< [tile.neighborArray count];i++)
    {
        // delete all neighbors + drop their columns
        Tile* neighborTile = tile.neighborArray[i];
        if(![neighborTile isEqual:_noTile])
        {
            neighborTile.remove = YES;
        }
    }
}

-(void) addBottomRow{
    // add a row to bottom of grid // incorrectly writing
    
    // shift everything up
    for (int i = 0; i < NUM_COLUMNS; i++) {
        for (int j = NUM_ROWS-1; j >= 0; j--) {
            
            Tile *currTile = _gridArray[i][j];
            // bad conditioning here
            if([currTile isEqual:_noTile] && j){
                continue;
            }
            
            // we have a tile, thats not bottom row
            if(![currTile isEqual:_noTile]) {
                // there's a tile and we need to move it up
                if(j == NUM_ROWS - 1){
                    // not safe to move up and just delete
                    // does this update the grid as well?
                }
                else{
                    // move up
                    currTile.position = [self positionForColumn:i row:j+1];
                    // [self moveTile:currTile newX:i newY:j+1];
                    _gridArray[i][j+1] = currTile; // want the value
                    _gridArray[i][j] = _noTile;
                    // need to call move function here.to have tiles drawn
                    
                    //
                }
                currTile = (Tile*) _noTile;
                
            }
            
            // im not creating these tiles correctly
            if(!j){
                // create new tile here
                // put get next tile here..
                Tile *tile = [self getNextTile:i row:j];
                _gridArray[i][j] = tile;
                
                
                NSLog(@"i: %d j: %d", i, j);
    
            }
            
        }
    }
    // [self updateTiles];
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
// is this initializing a class?????
-(Tile*)getNextTile:(int)column row:(int)row{
    Tile *tile = [[Tile alloc] initTile];
    tile.filename = self.nextTile.filename;
    tile.tileType = self.nextTile.tileType;
    [tile setTexture:[[CCSprite spriteWithImageNamed:tile.filename]texture]];
    tile.column = column;
    tile.row = row;
    tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
    tile.position = [self positionForColumn:column row:row];
    [self addChild:tile];
    [self.nextTile randomProperties];
    
    return tile;
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

-(BOOL)isGameOver{
    // checking top row for available slots
    for (int i = 0; i < NUM_COLUMNS; i++) {
        if([_gridArray[i][NUM_ROWS-1] isEqual:_noTile])
            return NO;
    }
    return YES;
}
@end