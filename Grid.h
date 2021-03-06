//
//  Grid.h
//  GolemBrick
//
//  Created by Alistair on 10/27/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Tile.h"

@interface Grid : CCNodeColor {
    
}

@property (nonatomic, strong) Tile* nextTile;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) long points;

@end
