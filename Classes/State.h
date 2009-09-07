#import <CoreData/CoreData.h>

@class City;

@interface State :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSSet* cities;

@end


@interface State (CoreDataGeneratedAccessors)
- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet *)value;
- (void)removeCities:(NSSet *)value;

- (NSString *)sectionCharacter;

@end

