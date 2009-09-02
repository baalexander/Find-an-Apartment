#import <UIKit/UIKit.h>

#import "PropertyHistory.h"


@interface PropertyHistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    @private
        //Core Data objects
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *propertyObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;

+ (PropertyHistory *)historyWithCopyOfCriteria:(PropertyCriteria *)criteria;
+ (void)deleteOldHistoryObjects:(NSManagedObjectContext *)managedObjectContext;

@end
