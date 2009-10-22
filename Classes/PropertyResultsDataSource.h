#import "PropertySummary.h"


@protocol PropertyResultsDataSource <NSObject>

@required
- (NSInteger)numberOfPropertiesInView:(UIView *)view;
- (PropertySummary *)view:(UIView *)view propertyAtIndex:(NSInteger)index;

@optional
- (void)view:(UIView *)view deletePropertyAtIndex:(NSInteger)index;

@end
