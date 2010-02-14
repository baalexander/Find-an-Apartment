#import <UIKit/UIKit.h>
#import "ARGeoViewController.h"
#import "PropertyArGeoCoordinate.h"
#import "PropertySummary.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"

@class PropertyArViewController;
@protocol PropertyArViewDelegate <NSObject>
- (void)arViewWillHide:(PropertyArViewController *)arView;
@end


@interface PropertyArViewController : ARGeoViewController <ARViewDelegate>
{
    @private
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
        UIViewController <PropertyArViewDelegate> *propertyArViewDelegate_;
        UIImagePickerController *camera_;
        UIImageView *popupView_;
        UIActivityIndicatorView *progressView_;
        UIView *locationLayerView_;
        NSMutableArray *locationViews_;
        NSMutableArray *locationItems_;
        NSMutableArray *baseItems_;
        PropertyArGeoCoordinate *selectedPoint_;
        BOOL recalibrateProximity_;
        BOOL popupIsAdded_;
        BOOL shouldChangeHighlight_;
        double minDistance_;
        NSInteger currentPage_;
        NSInteger contentType_;
        NSInteger locationCount_;
}

@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;
@property (nonatomic, assign) IBOutlet UIViewController <PropertyArViewDelegate> *propertyArViewDelegate;
@property (nonatomic, retain) UIImagePickerController *camera;

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;
- (IBAction)show;

@end
