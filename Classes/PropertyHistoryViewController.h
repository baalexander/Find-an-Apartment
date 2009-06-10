#import <UIKit/UIKit.h>


@interface PropertyHistoryViewController : UITableViewController
{
    @private
        //Core Data objects
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;

@end
