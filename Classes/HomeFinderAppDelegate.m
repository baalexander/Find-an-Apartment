#import "HomeFinderAppDelegate.h"

#import "PropertyStatesViewController.h"
#import "PropertyHistoryViewController.h"
#import "PropertyFavoritesViewController.h"
#import "MortgageCriteriaViewController.h"


@interface HomeFinderAppDelegate ()
@property (nonatomic, retain, readwrite) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *mortgageStoreCoordinator;
@end


@implementation HomeFinderAppDelegate

@synthesize mortgageObjectModel = mortgageObjectModel_;
@synthesize mortgageObjectContext = mortgageObjectContext_;
@synthesize mortgageStoreCoordinator = mortgageStoreCoordinator_;

#pragma mark -
#pragma mark HomeFinderAppDelegate

- (void)dealloc
{
    [mortgageObjectModel_ release];
    [mortgageObjectContext_ release];
    [mortgageStoreCoordinator_ release];
    
    [super dealloc];
}

- (NSManagedObjectModel *)mortgageObjectModel
{
    if (mortgageObjectModel_ == nil)
    {
        NSString *modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Mortgage" ofType:@"mom"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        [self setMortgageObjectModel:managedObjectModel];
        [managedObjectModel release];
    }
    
    return mortgageObjectModel_;
}

- (NSManagedObjectContext *)mortgageObjectContext
{
    if (mortgageObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setMortgageObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self mortgageObjectContext] setPersistentStoreCoordinator:[self mortgageStoreCoordinator]];
    }
    
    return mortgageObjectContext_;
}

- (NSPersistentStoreCoordinator *)mortgageStoreCoordinator
{
    if (mortgageStoreCoordinator_ == nil)
    {    
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mortgageObjectModel]];
        [self setMortgageStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Mortgage.sqlite"]];
        NSError *error;
        if (![[self mortgageStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            NSLog(@"Error adding persistent store coordinator for Mortgage model");
            //TODO: Handle error
        }    
    }
    
    return mortgageStoreCoordinator_;
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
        //If the visible view controller is a Mortgage Criteria view controller...
        else if ([visibleViewController isKindOfClass:[MortgageCriteriaViewController class]])
        {
            
        }
    }    
}

@end
