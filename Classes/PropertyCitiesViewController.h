#import <UIKit/UIKit.h>

#import "SaveAndRestoreProtocol.h"
#import "State.h"
#import "Locator.h"
#import "PropertyCriteria.h"


@interface PropertyCitiesViewController : UITableViewController <SaveAndRestoreProtocol, LocatorDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *propertyObjectContext_;
        State *state_;
        
        UISearchBar *searchBar_;
        UISearchDisplayController *searchDisplayController_;
        NSArray *filteredContent_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain) State *state;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *filteredContent;

@end
