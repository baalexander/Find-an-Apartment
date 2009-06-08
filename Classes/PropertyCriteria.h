#import <CoreData/CoreData.h>


@interface PropertyCriteria :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * sortBy;
@property (nonatomic, retain) NSString * coordinates;
@property (nonatomic, retain) NSString * maxBedrooms;
@property (nonatomic, retain) NSString * maxSquareFeet;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * minSquareFeet;
@property (nonatomic, retain) NSString * minPrice;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSString * maxBathrooms;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * searchSource;
@property (nonatomic, retain) NSString * minBedrooms;
@property (nonatomic, retain) NSString * maxPrice;
@property (nonatomic, retain) NSString * minBathrooms;
@property (nonatomic, retain) NSManagedObject * history;

@end



