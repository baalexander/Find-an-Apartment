#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyListViewController.h"
#import "PropertySummary.h"

@interface PropertyFavoritesViewController : PropertyListViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate>
{
}

+ (BOOL)addProperty:(PropertySummary *)summary;
+ (BOOL)isPropertyAFavorite:(PropertySummary *)summary;
+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext;

- (IBAction)share:(id)sender;
- (IBAction)edit:(id)sender;

@end
