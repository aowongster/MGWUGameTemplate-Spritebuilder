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
static const int DIFFICULTY = 2;

// this needs to be rewritten.

- (instancetype)initTile{
    [self randomProperties];
    self.neighborArray = [[NSMutableArray alloc] init];
    self = [super initWithImageNamed:self.filename];
    
    // not sure why image has to be setup out here
    // self = [super init];
    if (self) {
        self.remove = NO; // active for now at least
        // move this out?
        
        [self setScale:spriteScale];
        [self setAnchorPoint:ccp(0,0)];
        // [self randomProperties];
        
    }
    
    return self;
}
-(void) randomProperties {
    // init with random image?
    _tileNames = [NSArray arrayWithObjects:
                  @"stones/blue1.png",
                  @"stones/brown14.png",
                  @"stones/red10.png",
                  @"stones/grey9.png",
                  @"stones/orange5.png",
                  @"stones/grey18.png",
                  nil];
    
    self.tileType = arc4random_uniform((int)[_tileNames count] -DIFFICULTY);
    self.filename = _tileNames[self.tileType];
    // [self setTexture:[[CCSprite spriteWithImageNamed:self.filename]texture]];
    
}




@end
