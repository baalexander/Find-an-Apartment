#import <UIKit/UIKit.h>


@interface PropertyHistoryViewController : UITableViewController
{
    //Core Data objects
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
}

@end
