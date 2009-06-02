#import <CoreData/CoreData.h>

@class PropertyHistory;
@class PropertyDetails;

@interface PropertySummary :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) PropertyHistory * history;
@property (nonatomic, retain) PropertyDetails * details;

@end



