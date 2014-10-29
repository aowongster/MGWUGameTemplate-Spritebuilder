//
//  Tile.m
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "Tile.h"


@implementation Tile{
    
}
static const CGFloat  spriteScale = .5f;

- (instancetype)initTile{
    // since we made Creature inherit from CCSprite, 'super' below refers to CCSprite
    // init with random image?
    self = [super initWithImageNamed:@"stones/blue1.png"];
    
    if (self) {
        self.isActive = YES; // active for now at least
        // move this out?
        [self setScale:spriteScale];
        [self setAnchorPoint:ccp(0,0)];
        //self.position = ccp(x, y);
        
    }
    
    
    
    return self;
}

- (void)setIsActive:(BOOL)newState {
    //when you create an @property as we did in the .h, an instance variable with a leading underscore is automatically created for you
    _isActive = newState;
    
    // 'visible' is a property of any class that inherits from CCNode. CCSprite is a subclass of CCNode, and Creature is a subclass of CCSprite, so Creatures have a visible property
    self.visible = _isActive;
}

@end
