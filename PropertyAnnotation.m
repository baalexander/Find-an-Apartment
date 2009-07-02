//
//  PropertyAnnotation.m
//  Find an Apartment
//
//  Created by Tyler Pearson on 7/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PropertyAnnotation.h"


@implementation PropertyAnnotation

@synthesize coordinate = coordinate_;
@synthesize title = title_;
@synthesize subtitle = subtitle_;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if((self = [super init]))
    {
        coordinate_ = coordinate;
    }
    return self;
}

- (NSString *)title
{
    return [self title];
}

- (NSString *)subtitle
{
    return [self subtitle];
}

@end
