//
//  Tile.h
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Tile : CCSprite {

}
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) int tileType;

- (id)initTile;



@end
