#import <UIKit/UIKit.h>
@class LocationManager, PropertyCriteria;

@interface PropertyStatesViewController : UITableViewController
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
        NSManagedObjectContext *geographyObjectContext_;
        LocationManager *locationManager_;
}

- (void)useCriteria:(PropertyCriteria *)criteria;

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, assign) LocationManager *locationManager;

@end
