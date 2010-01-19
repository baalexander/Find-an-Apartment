#import <UIKit/UIKit.h>
#import "ARGeoViewController.h"
#import "PropertyArGeoCoordinate.h"
#import "PropertySummary.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"

@protocol ARPropViewDelegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;
- (void)onARControllerClose;

@end


@interface PropertyArViewController : ARGeoViewController
{
    @private
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
    //ARPropertyViewController *arkitViewController_;
	    UIImagePickerController *imgController_;
    
    @protected
        NSRange *widthViewportRange;
        NSRange *heightViewportRange;
        id propdelegate;

        NSArray *locationItems;
        NSMutableArray *locationViews;
        NSMutableArray *locationItemsInView;
        NSMutableArray *baseItems;
        UIImageView *popupView;
        UIView *contentView;
        UIView *locationLayerView;
        CGPoint gestureStartPoint;
        PropertyArGeoCoordinate *selectedPoint;
        PropertyArGeoCoordinate *selectedSubPoint;
        int contentType;
        NSString *currentRadius;
        UILabel *bottomView;
        UIImagePickerController *camera;
        UIActivityIndicatorView *progressView;

        bool popupIsAdded;
        bool updatedLocations;
        bool shouldChangeHighlight;
        bool recalibrateProximity;
        double minDistance; // used for calculating inclination
        int currentPage; // current page selected of subitems
}

@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;
@property (nonatomic, assign) UIImagePickerController *imgController;
//@property (nonatomic, retain) IBOutlet ARPropertyViewController *arkitViewController;

// Start of ARProperty
@property (nonatomic, assign) id propdelegate;
@property (nonatomic, retain) NSArray *locationItems;
@property (nonatomic, copy) NSMutableArray *locationViews;
@property (nonatomic, retain) NSMutableArray *locationItemsInView;
@property (nonatomic, retain) NSMutableArray *baseItems;
@property (nonatomic, retain) UIImageView *popupView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *locationLayerView;
@property (nonatomic, retain) PropertyArGeoCoordinate *selectedPoint;
@property (nonatomic, retain) PropertyArGeoCoordinate *selectedSubPoint;
@property (nonatomic, retain) NSString *currentRadius;
@property (nonatomic, retain) UILabel *bottomView;
@property (nonatomic, retain) UIImagePickerController *camera;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;

@property bool popupIsAdded;
@property int contentType;
@property bool updatedLocations;
@property bool shouldChangeHighlight;
@property bool recalibrateProximity;
@property double minDistance;
@property int currentPage;
@property CGPoint gestureStartPoint;
// End of ARProperty

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;

// Start of ARProperty
- (void)startListening;
- (void)updateLocations;
- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate;
- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;
- (bool)isNearCoordinate:(PropertyArGeoCoordinate *)coord newCoordinate:(PropertyArGeoCoordinate *)newCoord;
- (void)updateProximityLocations;
- (void)makePanel;
// End of ARProperty

@end
