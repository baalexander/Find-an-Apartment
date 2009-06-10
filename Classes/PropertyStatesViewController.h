#import <UIKit/UIKit.h>


@interface PropertyStatesViewController : UITableViewController
{
    @private
        NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
