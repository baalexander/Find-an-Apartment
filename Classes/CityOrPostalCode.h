#import <CoreData/CoreData.h>

@class State;

@interface CityOrPostalCode :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * isCity;
@property (nonatomic, retain) State * state;

@end



