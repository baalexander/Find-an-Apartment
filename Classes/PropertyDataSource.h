#import "PropertySummary.h"


@protocol PropertyDataSource <NSObject>

@required
- (NSInteger)propertyCount;
- (PropertySummary *)propertyAtIndex:(NSInteger)index;
- (BOOL)deletePropertyAtIndex:(NSInteger)index;

@end
