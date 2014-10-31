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
    
    
    // self = [super init];
    if (self) {
        self.isActive = YES; // active for now at least
        // move this out?
        [self setScale:spriteScale];
        [self setAnchorPoint:ccp(0,0)];
        [self randomProperties];
        
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
    //when you create an @property as we did in the .h, an instance variable with a leading underscore is automatically created for you
    _isActive = newState;
    
    // 'visible' is a property of any class that inherits from CCNode. CCSprite is a subclass of CCNode, and Creature is a subclass of CCSprite, so Creatures have a visible property
    self.visible = _isActive;
}

@end
