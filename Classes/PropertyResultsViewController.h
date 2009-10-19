#import <UIKit/UIKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "PropertyDataSource.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetails.h"
#import "PropertyListViewController.h"
#import "PropertyMapViewController.h"
#import "PropertyGeocoder.h"


@interface PropertyResultsViewController : UIViewController <PropertyDataSource, PropertyGeocoderDelegate, ParserDelegate>
{    
    @private
        // Sub-view controllers
        PropertyListViewController *listViewController_;
        PropertyMapViewController *mapViewController_;
    
        // Core data
        PropertyHistory *history_;
        PropertySummary *summary_;
        PropertyDetails *details_;
        NSFetchedResultsController *fetchedResultsController_;
    
        //Queues parsing thread
        NSOperationQueue *operationQueue_;
    
        // Determines if view controller is in the middle of a parsing operation
        BOOL isParsing_;
    
        // Geocoding
        NSMutableArray *geocodedProperties_;
    
        UIAlertView *alertView_;
}

@property (nonatomic, retain) PropertyHistory *history;

@property (nonatomic, retain) IBOutlet PropertyListViewController *listViewController;
@property (nonatomic, retain) IBOutlet PropertyMapViewController *mapViewController;

- (void)parse:(NSURL *)url;

@end
