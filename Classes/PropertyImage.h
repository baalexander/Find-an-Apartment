#import <CoreData/CoreData.h>

@class PropertyDetails;

@interface PropertyImage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) PropertyDetails * details;

@end



