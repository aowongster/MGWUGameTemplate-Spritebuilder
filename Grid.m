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
}
static const NSInteger GRID_SIZE = 6;
static const CGFloat  spriteScale = .5f;

- (void)setupBackground
{
	// load one tile to read the dimensions
	CCNode *tile = [CCBReader load:@"Tile"];
    
    // these guys are fixed
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
    
	for (int i = 0; i < GRID_SIZE; i++) {
		// iterate through each row
		x = _tileMarginHorizontal;
		for (int j = 0; j < GRID_SIZE; j++) {
			//  iterate through each column in the current row
            
            // add sprite.
			CCSprite *spriteTile = [CCSprite spriteWithImageNamed:@"stones/blue1.png"];
            [spriteTile setScale:spriteScale];
			spriteTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
            [spriteTile setAnchorPoint:ccp(0,0)];
			spriteTile.position = ccp(x, y);
            
            
            // add grid
            CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor brownColor]];
			backgroundTile.contentSize = CGSizeMake(_columnWidth, _columnHeight);
			backgroundTile.position = ccp(x, y);
           
			
            
			[self addChild:backgroundTile];
            //[self addChild:spriteTile];
			x+= _columnWidth + _tileMarginHorizontal;
		}
		y += _columnHeight + _tileMarginVertical;
	}
}

- (void)didLoadFromCCB {
	[self setupBackground];
}

@end