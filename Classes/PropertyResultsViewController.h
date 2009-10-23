#import <UIKit/UIKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "PropertyResultsDelegate.h"
#import "PropertyResultsDataSource.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetails.h"
#import "PropertyListViewController.h"
#import "PropertyMapViewController.h"
#import "Geocoder.h"


@interface PropertyResultsViewController : UIViewController <PropertyResultsDelegate,
                                                             PropertyResultsDataSource,
                                                             GeocoderDelegate,
                                                             ParserDelegate>
{    
    @private
        // Sub-view controllers
        PropertyListViewController *listViewController_;
        PropertyMapViewController *mapViewController_;
    
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
    
        UIAlertView *alertView_;
}

@property (nonatomic, retain) PropertyHistory *history;

@property (nonatomic, retain) IBOutlet PropertyListViewController *listViewController;
@property (nonatomic, retain) IBOutlet PropertyMapViewController *mapViewController;

// This would be "protected" for Favorites to use, if such a thing existed
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)parse:(NSURL *)url;
- (IBAction)changeView:(id)sender;

@end
