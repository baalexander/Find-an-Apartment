#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyResultsViewController.h"
#import "PropertySummary.h"


@interface PropertyFavoritesViewController : PropertyResultsViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate>
{
    
}

+ (BOOL)addCopyOfProperty:(PropertySummary *)property;
+ (BOOL)isPropertyAFavorite:(PropertySummary *)property;
+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext;

- (IBAction)share:(id)sender;
- (IBAction)edit:(id)sender;

@end
