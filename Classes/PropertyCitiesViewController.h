#import <UIKit/UIKit.h>

#import "State.h"
@class LocationManager, PropertyCriteria;


@interface PropertyCitiesViewController : UITableViewController
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
        State *state_;
        LocationManager *locationManager_;
}

- (void)useCriteria:(PropertyCriteria *)criteria;

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain) State *state;
@property (nonatomic, assign) LocationManager *locationManager;

@end
