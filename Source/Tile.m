//
//  Tile.m
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Tile.h"


@implementation Tile{
    // implement types here
    // int *_tileType;
    NSArray *_tileNames;
    
}
static const CGFloat  spriteScale = .5f;
static const int DIFFICULTY = 0;

// this needs to be rewritten.

- (instancetype)initTile:(int)column row:(int)row{
    
    self = [super init];
    if (self) {
        
        self.column = column;
        self.row = row;
        self.remove = NO;
        self.neighborArray = [[NSMutableArray alloc] init];
        [self randomProperties];
        [self setScale:spriteScale];
        [self setAnchorPoint:ccp(0,0)];
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:self.filename];
    }
    
    return self;
}

-(instancetype)initTile{
    return [self initTile:0 row:0];
}

-(void) randomProperties {
    // init with random image?
    _tileNames = [NSArray arrayWithObjects:
                  @"stones/blue6.png",
                  @"stones/brown6.png",
                  @"stones/red6.png",
                  @"stones/grey6.png",
                  @"stones/orange6.png",
                  @"stones/grey6.png",
                  @"stones/green6.png",
                  @"stones/pink6.png",
                  nil];
    
    self.tileType = arc4random_uniform((int)[_tileNames count] -DIFFICULTY);
    self.filename = _tileNames[self.tileType];
}




@end
