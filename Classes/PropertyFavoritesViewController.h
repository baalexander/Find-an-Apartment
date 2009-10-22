#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyResultsViewController.h"
#import "PropertySummary.h"

@interface PropertyFavoritesViewController : PropertyResultsViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate>
{
    
}

+ (BOOL)addCopyOfProperty:(PropertySummary *)summary;
+ (BOOL)isPropertyAFavorite:(PropertySummary *)summary;
+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext;

- (IBAction)share:(id)sender;
- (IBAction)edit:(id)sender;

@end
