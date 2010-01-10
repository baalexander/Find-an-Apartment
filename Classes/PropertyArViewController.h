#import <UIKit/UIKit.h>
#import "ARPropertyViewController.h"
#import "PropertySummary.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"


@interface PropertyArViewController : ARPropertyViewController
{
    @private
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
		ARPropertyViewController *arkitViewController_;
	    UIImagePickerController *imgController_;
}

@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;
@property (nonatomic, assign) UIImagePickerController *imgController;
@property (nonatomic, retain) IBOutlet ARPropertyViewController *arkitViewController;

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;

@end
