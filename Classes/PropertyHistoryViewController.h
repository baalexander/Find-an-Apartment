#import <UIKit/UIKit.h>

#import "PropertyHistory.h"


@interface PropertyHistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    @private
        //Core Data objects
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;

+ (PropertyHistory *)historyWithCopyOfCriteria:(PropertyCriteria *)criteria;
+ (void)deleteOldHistoryObjects:(NSManagedObjectContext *)managedObjectContext;

@end
