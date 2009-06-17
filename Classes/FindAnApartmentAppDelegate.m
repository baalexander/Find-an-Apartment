#import "FindAnApartmentAppDelegate.h"

#import "PropertyStatesViewController.h"
#import "PropertyHistoryViewController.h"
#import "PropertyFavoritesViewController.h"
#import "State.h"
#import "City.h"
#import "PostalCode.h"


@interface FindAnApartmentAppDelegate ()

@property (nonatomic, retain, readwrite) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain, readwrite) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *mainStoreCoordinator;

@property (nonatomic, retain, readwrite) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *geographyStoreCoordinator;

@end


@implementation FindAnApartmentAppDelegate

@synthesize window = window_;
@synthesize tabBarController = tabBarController_;
@synthesize statesViewController = statesViewController_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize mainObjectContext = mainObjectContext_;
@synthesize mainStoreCoordinator = mainStoreCoordinator_;
@synthesize geographyObjectContext = geographyObjectContext_;
@synthesize geographyStoreCoordinator = geographyStoreCoordinator_;


#pragma mark -
#pragma mark FindAnApartmentAppDelegate

- (void)dealloc
{
    [tabBarController_ release];
	[window_ release];
    [managedObjectModel_ release];
    [mainObjectContext_ release];
    [mainStoreCoordinator_ release];
    [geographyObjectContext_ release];
    [geographyStoreCoordinator_ release];
    
	[super dealloc];
}

//Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

//Created object model based on *all* models found in the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ == nil)
    {
        [self setManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    }
    
    return managedObjectModel_;
}

- (NSManagedObjectContext *)mainObjectContext
{
    if (mainObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setMainObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self mainObjectContext] setPersistentStoreCoordinator:[self mainStoreCoordinator]];
    }
    
    return mainObjectContext_;
}

- (NSPersistentStoreCoordinator *)mainStoreCoordinator
{
    if (mainStoreCoordinator_ == nil)
    {	
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [self setMainStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        
        NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Find_an_Apartment.sqlite"]];
        NSError *error;
        if (![[self mainStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            NSLog(@"Error adding persistent store coordinator for main model");
            //TODO: Handle error
        }    
    }
	
    return mainStoreCoordinator_;
}

- (NSManagedObjectContext *)geographyObjectContext
{
    if (geographyObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setGeographyObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self geographyObjectContext] setPersistentStoreCoordinator:[self geographyStoreCoordinator]];
    }
    
    return geographyObjectContext_;
}

//Geographical data is stored in its own persistent storage
- (NSPersistentStoreCoordinator *)geographyStoreCoordinator
{
    if (geographyStoreCoordinator_ == nil)
    {	
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [self setGeographyStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        
        NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Geography.sqlite"]];
        NSError *error;
        if (![[self geographyStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            NSLog(@"Error adding persitent store for Geography");
            //TODO: Handle error
        }    
    }
	
    return geographyStoreCoordinator_;
}


#pragma mark -
#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [[self statesViewController] setMainObjectContext:[self mainObjectContext]];
    [[self statesViewController] setGeographyObjectContext:[self geographyObjectContext]];
    [[self window] addSubview:[[self tabBarController] view]];
    [[self window] makeKeyAndVisible];
}

//applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application
{	
    NSError *error;
    if (mainObjectContext_ != nil)
    {
        if ([[self mainObjectContext] hasChanges] && ![[self mainObjectContext] save:&error])
        {
			// Handle error
            NSLog(@"Error when saving context in application will terminate.");
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
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
            [statesViewController setMainObjectContext:[self mainObjectContext]];
            [statesViewController setGeographyObjectContext:[self geographyObjectContext]];
        }
        //If the visibile view controller is a Property History view controller...
        else if ([visibleViewController isKindOfClass:[PropertyHistoryViewController class]])
        {
            PropertyHistoryViewController *historyViewController = (PropertyHistoryViewController *)visibleViewController;
            [historyViewController setMainObjectContext:[self mainObjectContext]];
            
        }
        //If the visibile view controller is a Property Favorites view controller...
        else if ([visibleViewController isKindOfClass:[PropertyFavoritesViewController class]])
        {
            PropertyFavoritesViewController *favoritesViewController = (PropertyFavoritesViewController *)visibleViewController;
            //History will be nil the first time initializing the view controller
            //This check avoids an unnecessary fetch
            if ([favoritesViewController history] == nil)
            {
                PropertyHistory *history = [PropertyFavoritesViewController favoriteHistoryFromContext:[self mainObjectContext]];
                [favoritesViewController setHistory:history];
            }
        }
    }    
}

@end
