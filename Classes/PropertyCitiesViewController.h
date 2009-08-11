#import <UIKit/UIKit.h>

#import "State.h"


@class LocationManager, PropertyCriteria;


@interface PropertyCitiesViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *propertyObjectContext_;
        State *state_;
        LocationManager *locationManager_;
        
        UISearchBar *searchBar_;
        UISearchDisplayController *searchDisplayController_;
        NSArray *filteredContent_;
}

- (void)useCriteria:(PropertyCriteria *)criteria;

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain) State *state;
@property (nonatomic, assign) LocationManager *locationManager;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *filteredContent;

@end
