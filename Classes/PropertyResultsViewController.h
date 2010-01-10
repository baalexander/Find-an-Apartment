#import <UIKit/UIKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "PropertyResultsDelegate.h"
#import "PropertyResultsDataSource.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetails.h"
#import "PropertyListViewController.h"
#import "PropertyMapViewController.h"
#import "PropertyArViewController.h"
#import "Geocoder.h"
#import "ARGeoViewController.h"

@interface PropertyResultsViewController : UIViewController <PropertyResultsDelegate,
                                                             PropertyResultsDataSource,
                                                             GeocoderDelegate,
                                                             XmlParserDelegate,
                                                             UIAlertViewDelegate>
{    
    @private
        // Sub-view controllers
        PropertyListViewController *listViewController_;
        PropertyMapViewController *mapViewController_;
        PropertyArViewController *arViewController_;
    
        // Core data
        PropertyHistory *history_;
        PropertySummary *property_;
        PropertyDetails *details_;
        NSFetchedResultsController *fetchedResultsController_;
    
        // Parsing
        NSOperationQueue *operationQueue_;
        BOOL parsing_;
    
        // Geocoding
        Geocoder *geocoder_;
        NSInteger geocodeIndex_;
        BOOL geocoding_;
        BOOL mapIsDirty_;
    
		// Misc
        UIAlertView *alertView_;
		UISegmentedControl *segmentedControl_;
		int previousSelectedSegment_;
		UIImagePickerController *camera_;
}

@property (nonatomic, retain) PropertyHistory *history;

@property (nonatomic, retain) IBOutlet PropertyListViewController *listViewController;
@property (nonatomic, retain) IBOutlet PropertyMapViewController *mapViewController;
@property (nonatomic, retain) IBOutlet PropertyArViewController *arViewController;

// These would be "protected" for Favorites to use, if such a thing existed
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL mapIsDirty;
@property (nonatomic, retain) UIImagePickerController *camera;

- (void)parse:(NSURL *)url;
- (void)geocodeNextProperty;
- (void)resetGeocoding;
- (IBAction)changeView:(id)sender;
- (UIView *)viewForCoordinate:(PropertyARGeoCoordinate *)coordinate;

@end
