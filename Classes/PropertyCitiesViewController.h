#import <UIKit/UIKit.h>

#import "State.h"


@interface PropertyCitiesViewController : UITableViewController
{
    @private
        NSFetchedResultsController *fetchedResultsController_;
        NSManagedObjectContext *mainObjectContext_;
        State *state_;
}

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain) State *state;

@end
