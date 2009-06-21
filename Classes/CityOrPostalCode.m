// 
//  CityOrPostalCode.m
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CityOrPostalCode.h"

#import "State.h"

@implementation CityOrPostalCode 

@dynamic value;
@dynamic isCity;
@dynamic state;

- (NSString *)sectionCharacter {
    return [[self value] substringToIndex:1];
}


@end
