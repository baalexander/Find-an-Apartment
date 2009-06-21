//
//  CityOrPostalCode.h
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class State;

@interface CityOrPostalCode :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * isCity;
@property (nonatomic, retain) State * state;

@end



