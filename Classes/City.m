// 
//  City.m
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "City.h"

#import "State.h"

@implementation City 

@dynamic name;
@dynamic state;

- (NSString *)sectionCharacter {
    return [[self name] substringToIndex:1];
}

@end
