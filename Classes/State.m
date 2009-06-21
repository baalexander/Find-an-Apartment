// 
//  State.m
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "State.h"

#import "CityOrPostalCode.h"

@implementation State 

@dynamic name;
@dynamic abbreviation;
@dynamic citiesAndPostalCodes;

- (NSString *)sectionCharacter {
    return [[self name] substringToIndex:1];
}


@end
