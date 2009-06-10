//
//  PostalCode.h
//  Find an Apartment
//
//  Created by Brandon Alexander on 6/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class State;
@class City;

@interface PostalCode :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) State * state;
@property (nonatomic, retain) City * city;

@end



