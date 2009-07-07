#import "HomeFinderAppDelegate.h"

#import "PropertyStatesViewController.h"
#import "PropertyHistoryViewController.h"
#import "PropertyFavoritesViewController.h"


@implementation HomeFinderAppDelegate


#pragma mark -
#pragma mark HomeFinderAppDelegate

- (void)dealloc
{
    [super dealloc];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //Figure out the view controller type to pass any values needed before hitting it the first time. Like managed object contexts.
    //Will only be comparing the view controller to the root view controller of each tab. If not the root view controller, then the view controller is a child of the root view controller implying the root view controller has already been initialized with the correct parameters so nothing to do.
    
    //If a navigation controller, then need to figure its visible view controller.
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationViewController = (UINavigationController *)viewController;
        UIViewController *visibleViewController = [navigationViewController visibleViewController];
        //If the visibile view controller is a Property States view controller...
        if ([visibleViewController isKindOfClass:[PropertyStatesViewController class]])
        {
            PropertyStatesViewController *statesViewController = (PropertyStatesViewController *)visibleViewController;
            [statesViewController setPropertyObjectContext:[self propertyObjectContext]];
            [statesViewController setGeographyObjectContext:[self geographyObjectContext]];
        }
        //If the visibile view controller is a Property History view controller...
        else if ([visibleViewController isKindOfClass:[PropertyHistoryViewController class]])
        {
            PropertyHistoryViewController *historyViewController = (PropertyHistoryViewController *)visibleViewController;
            [historyViewController setPropertyObjectContext:[self propertyObjectContext]];
            
        }
        //If the visibile view controller is a Property Favorites view controller...
        else if ([visibleViewController isKindOfClass:[PropertyFavoritesViewController class]])
        {
            PropertyFavoritesViewController *favoritesViewController = (PropertyFavoritesViewController *)visibleViewController;
            //History will be nil the first time initializing the view controller
            //This check avoids an unnecessary fetch
            if ([favoritesViewController history] == nil)
            {
                PropertyHistory *history = [PropertyFavoritesViewController favoriteHistoryFromContext:[self propertyObjectContext]];
                [favoritesViewController setHistory:history];
            }
        }
    }    
}

@end
