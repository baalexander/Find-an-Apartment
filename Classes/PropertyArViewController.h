#import <UIKit/UIKit.h>
#import "ARGeoViewController.h"
#import "PropertySummary.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"


@interface PropertyArViewController : ARGeoViewController
{
    @private
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
		ARGeoViewController *arkitViewController_;
	    UIImagePickerController *imgController_;
}

@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;
@property (nonatomic, assign) UIImagePickerController *imgController;
@property (nonatomic, retain) IBOutlet ARGeoViewController *arkitViewController;

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;

@end
