#import <CoreData/CoreData.h>

@class CityOrPostalCode;

@interface State :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSSet* citiesAndPostalCodes;

@end


@interface State (CoreDataGeneratedAccessors)
- (void)addCitiesAndPostalCodesObject:(CityOrPostalCode *)value;
- (void)removeCitiesAndPostalCodesObject:(CityOrPostalCode *)value;
- (void)addCitiesAndPostalCodes:(NSSet *)value;
- (void)removeCitiesAndPostalCodes:(NSSet *)value;

@end

