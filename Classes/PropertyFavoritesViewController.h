#import <Foundation/Foundation.h>

#import "PropertyListViewController.h"
#import "PropertySummary.h"

@interface PropertyFavoritesViewController : PropertyListViewController
{
}

+ (BOOL)addProperty:(PropertySummary *)summary;
+ (BOOL)isPropertyAFavorite:(PropertySummary *)summary;
+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext;

@end
