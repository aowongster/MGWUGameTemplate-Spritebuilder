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

- (instancetype)initTile{
    // init with random image?
    _tileNames = [NSArray arrayWithObjects:
                  @"stones/blue1.png",
                  @"stones/brown14.png",
                  @"stones/red10.png",
                  @"stones/grey9.png",
                  @"stones/orange5.png",
                  @"stones/grey18.png",
                  nil];
    
    self.tileType = arc4random_uniform([_tileNames count] -1);
    self.filename = _tileNames[self.tileType];
    self = [super initWithImageNamed:self.filename];
    
    // not sure why image has to be setup out here
    // self = [super init];
    if (self) {
        self.isActive = YES; // active for now at least
        // move this out?
        [self setScale:spriteScale];
        [self setAnchorPoint:ccp(0,0)];
        // [self randomProperties];
        
    }
    
    return self;
}

- (NSString*) getNewFilename{
    
    int rand = arc4random_uniform([_tileNames count] -1);
    return _tileNames[rand];
    
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
    
    self.tileType = arc4random_uniform([_tileNames count] -1);
    self.filename = _tileNames[self.tileType];
    [self setTexture:[[CCSprite spriteWithImageNamed:self.filename]texture]];
    
}

- (void)setIsActive:(BOOL)newState {
    _isActive = newState;
    self.visible = _isActive;
}

@end
