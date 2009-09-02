#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SaveAndRestoreProtocol.h"
#import "Locator.h"
#import "PropertyCriteria.h"


@interface PropertyStatesViewController : UITableViewController <SaveAndRestoreProtocol, LocatorDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *propertyObjectContext_;
        NSManagedObjectContext *geographyObjectContext_;
    
        UISearchBar *searchBar_;
        UISearchDisplayController *searchDisplayController_;
        NSArray *filteredContent_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *geographyObjectContext;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *filteredContent;

@end
