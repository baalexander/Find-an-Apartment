#import <UIKit/UIKit.h>


@interface PropertyHistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    @private
        //Core Data objects
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;

@end
