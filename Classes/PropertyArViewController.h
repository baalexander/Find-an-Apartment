#import <UIKit/UIKit.h>
#import "ARGeoViewController.h"
#import "PropertySummary.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"


@interface PropertyArViewController : ARGeoViewController <ARViewDelegate>
{
    @private
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
}

@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;

@end
