//
//  City.h
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class State;

@interface City :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) State * state;

@end



