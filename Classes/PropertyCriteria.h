#import <CoreData/CoreData.h>

@class PropertyHistory;

@interface PropertyCriteria :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * sortBy;
@property (nonatomic, retain) NSString * coordinates;
@property (nonatomic, retain) NSNumber * maxBedrooms;
@property (nonatomic, retain) NSNumber * maxSquareFeet;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * minSquareFeet;
@property (nonatomic, retain) NSNumber * minPrice;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSNumber * maxBathrooms;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * searchSource;
@property (nonatomic, retain) NSNumber * minBedrooms;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSNumber * minBathrooms;
@property (nonatomic, retain) PropertyHistory * history;

@end



