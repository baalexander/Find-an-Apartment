#import <UIKit/UIKit.h>

#import "SaveAndRestoreProtocol.h"
#import "State.h"
#import "LocationManager.h"
#import "PropertyCriteria.h"


@interface PropertyCitiesViewController : UITableViewController <SaveAndRestoreProtocol, UISearchDisplayDelegate, UISearchBarDelegate>
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
