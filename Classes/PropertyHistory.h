#import <CoreData/CoreData.h>

@class PropertyCriteria;
@class PropertySummary;

@interface PropertyHistory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) PropertyCriteria * criteria;
@property (nonatomic, retain) NSSet* summaries;

@end


@interface PropertyHistory (CoreDataGeneratedAccessors)
- (void)addSummariesObject:(PropertySummary *)value;
- (void)removeSummariesObject:(PropertySummary *)value;
- (void)addSummaries:(NSSet *)value;
- (void)removeSummaries:(NSSet *)value;

@end

