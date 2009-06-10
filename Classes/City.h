//
//  City.h
//  Find an Apartment
//
//  Created by Brandon Alexander on 6/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class State;
@class PostalCode;

@interface City :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) State * state;
@property (nonatomic, retain) NSSet* postalCodes;

@end


@interface City (CoreDataGeneratedAccessors)
- (void)addPostalCodesObject:(PostalCode *)value;
- (void)removePostalCodesObject:(PostalCode *)value;
- (void)addPostalCodes:(NSSet *)value;
- (void)removePostalCodes:(NSSet *)value;

@end

