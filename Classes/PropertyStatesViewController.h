#import <UIKit/UIKit.h>


@interface PropertyStatesViewController : UITableViewController
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
        NSManagedObjectContext *geographyObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *geographyObjectContext;

@end
