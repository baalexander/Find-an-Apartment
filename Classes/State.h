//
//  State.h
//  Find an Apartment
//
//  Created by Tyler Pearson on 6/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class City;
@class PostalCode;

@interface State :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSSet* cities;
@property (nonatomic, retain) NSSet* postalCodes;

@end


@interface State (CoreDataGeneratedAccessors)
- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet *)value;
- (void)removeCities:(NSSet *)value;

- (void)addPostalCodesObject:(PostalCode *)value;
- (void)removePostalCodesObject:(PostalCode *)value;
- (void)addPostalCodes:(NSSet *)value;
- (void)removePostalCodes:(NSSet *)value;

@end

