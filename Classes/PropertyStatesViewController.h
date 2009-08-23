#import <UIKit/UIKit.h>

#import "SaveAndRestoreProtocol.h"
#import "LocationManager.h"
#import "PropertyCriteria.h"


@interface PropertyStatesViewController : UITableViewController <SaveAndRestoreProtocol, UISearchDisplayDelegate, UISearchBarDelegate>
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *propertyObjectContext_;
        NSManagedObjectContext *geographyObjectContext_;
        LocationManager *locationManager_;
        NSString *state_;
    
        UISearchBar *searchBar_;
        UISearchDisplayController *searchDisplayController_;
        NSArray *filteredContent_;
}

- (void)useCriteria:(PropertyCriteria *)criteria;

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, assign) LocationManager *locationManager;
@property (nonatomic, copy) NSString *state;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *filteredContent;

@end
