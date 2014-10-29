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

- (void)didLoadFromCCB {
	[self setupBackground];
    
    _noTile = [NSNull null];
	_gridArray = [NSMutableArray array];
	for (int i = 0; i < GRID_SIZE; i++) {
		_gridArray[i] = [NSMutableArray array];
		for (int j = 0; j < GRID_SIZE; j++) {
			_gridArray[i][j] = _noTile;
		}
	}
    self.userInteractionEnabled = TRUE;
    
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
    NSLog(@"%f %f", touchLocation.x, touchLocation.y);
    
    // make a move
    int touchColumn = [self columnForTouchPosition:touchLocation];
    NSLog(@"touch Column %d", touchColumn);
    
    int availableRow = [self nextAvailableRow:touchColumn];
    if(availableRow>=0){
        NSLog(@"spot open in column %d", touchColumn);
        // drop a tile in the spot
        // create a tile and move to newX newY
        Tile *tile = [[Tile alloc] initTile];
        tile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
        
        // position called again in moveTile
        tile.position = [self positionForColumn:touchColumn row:availableRow];
        NSLog(@"x: %f, y:%f", tile.position.x, tile.position.y);
        [self addChild:tile];
        
        // - (void)moveTile:(Tile *)tile newX:(NSInteger)newX newY:(NSInteger)newY {
        // _gridArray[availableRow][touchColumn] = tile;
        //[self moveTile:tile newX:availableRow newY:touchColumn];
        [self moveTile:tile newX:touchColumn newY:availableRow];
    }
    else{
        NSLog(@"Column Full");
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
    int oldX = newX;
    int oldY = GRID_SIZE - 1;
    _gridArray[newX][newY] = tile;
    // _gridArray[oldX][oldY] = _noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
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
	NSInteger x = 2 * _tileMarginHorizontal + column * (_tileMarginHorizontal + _columnWidth);
	NSInteger y = (-0.5f * _tileMarginVertical) + row * (_tileMarginVertical + _columnHeight);
	return CGPointMake(x,y);
}
@end