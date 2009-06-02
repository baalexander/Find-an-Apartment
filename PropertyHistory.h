#import <CoreData/CoreData.h>

@class PropertyCriteria;

@interface PropertyHistory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) PropertyCriteria * criteria;
@property (nonatomic, retain) NSSet* summaries;

@end


@interface PropertyHistory (CoreDataGeneratedAccessors)
- (void)addSummariesObject:(NSManagedObject *)value;
- (void)removeSummariesObject:(NSManagedObject *)value;
- (void)addSummaries:(NSSet *)value;
- (void)removeSummaries:(NSSet *)value;

@end

