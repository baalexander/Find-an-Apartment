#import <UIKit/UIKit.h>
@class LocationManager, PropertyCriteria;

@interface PropertyStatesViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
        NSManagedObjectContext *geographyObjectContext_;
        LocationManager *locationManager_;
    
        UISearchBar *searchBar_;
        UISearchDisplayController *searchDisplayController_;
        NSArray *filteredContent_;
}

- (void)useCriteria:(PropertyCriteria *)criteria;

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, assign) LocationManager *locationManager;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *filteredContent;

@end
