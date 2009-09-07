#import "AppDelegate.h"

#import "PropertyStatesViewController.h"
#import "PropertyHistoryViewController.h"
#import "PropertyFavoritesViewController.h"
#import "SaveAndRestoreConstants.h"

#ifdef HOME_FINDER
    #import "MortgageCriteriaViewController.h"
#endif


@interface AppDelegate ()

@property (nonatomic, retain, readwrite) NSManagedObjectModel *propertyObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *propertyStoreCoordinator;

@property (nonatomic, retain, readwrite) NSManagedObjectModel *geographyObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *geographyStoreCoordinator;

- (void)populateViewController:(UIViewController *)viewController;

@end


@implementation AppDelegate

@synthesize window = window_;
@synthesize tabBarController = tabBarController_;
@synthesize propertyObjectModel = propertyObjectModel_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize propertyStoreCoordinator = propertyStoreCoordinator_;
@synthesize geographyObjectModel = geographyObjectModel_;
@synthesize geographyObjectContext = geographyObjectContext_;
@synthesize geographyStoreCoordinator = geographyStoreCoordinator_;


#pragma mark -
#pragma mark AppDelegate

- (void)dealloc
{
    [tabBarController_ release];
    [window_ release];
    [propertyObjectModel_ release];
    [propertyObjectContext_ release];
    [propertyStoreCoordinator_ release];
    [geographyObjectModel_ release];
    [geographyObjectContext_ release];
    [geographyStoreCoordinator_ release];    
    [super dealloc];
}

//Returns the path to the application's documents directory.
+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (NSManagedObjectModel *)propertyObjectModel
{
    if (propertyObjectModel_ == nil)
    {
        NSString *modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Property" ofType:@"mom"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        [self setPropertyObjectModel:managedObjectModel];
        [managedObjectModel release];
    }
    
    return propertyObjectModel_;
}

- (NSManagedObjectContext *)propertyObjectContext
{
    if (propertyObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setPropertyObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self propertyObjectContext] setPersistentStoreCoordinator:[self propertyStoreCoordinator]];
    }
    
    return propertyObjectContext_;
}

- (NSPersistentStoreCoordinator *)propertyStoreCoordinator
{
    if (propertyStoreCoordinator_ == nil)
    {    
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self propertyObjectModel]];
        [self setPropertyStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        NSURL *storeUrl = [NSURL fileURLWithPath:[[AppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"Property.sqlite"]];
        NSError *error;
        if (![[self propertyStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            DebugLog(@"Error adding persistent store coordinator for Property model");
        }    
    }
    
    return propertyStoreCoordinator_;
}

- (NSManagedObjectModel *)geographyObjectModel
{
    if (geographyObjectModel_ == nil)
    {
        NSString *modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Geography" ofType:@"mom"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        [self setGeographyObjectModel:managedObjectModel];
        [managedObjectModel release];
    }
    
    return geographyObjectModel_;
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
        NSString *storePath = [[AppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"Geography.sqlite"];
        
        // Check to see if the store already exists
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // Copy the default store if necessary
        if (![fileManager fileExistsAtPath:storePath]) 
        {
            NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Geography" ofType:@"sqlite"];
            if (defaultStorePath) 
            {
                [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
            }
        }
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self geographyObjectModel]];
        [self setGeographyStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        
        NSMutableDictionary *options = nil;
        //Implement options when updating the model. Then comment options back out.
        //options = [NSMutableDictionary dictionary];
        //Uncomment the line below to ignore version hash checks
        //[options setObject:[NSNumber numberWithBool:YES] forKey:NSIgnorePersistentStoreVersioningOption];
        //When migrating, uncomment the setObject lines belows
        //[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        //[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];        
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        NSError *error;
        if (![[self geographyStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
        {
            // Handle the error.
            DebugLog(@"error: %@", error);
        }
    }
    
    return geographyStoreCoordinator_;
}


#pragma mark -
#pragma mark SaveAndRestoreProtocol

- (void)restore
{
    //Load the previous tab
    NSInteger tab = [[NSUserDefaults standardUserDefaults] integerForKey:kSavedTab];
    
    NSArray *viewControllers = [[self tabBarController] viewControllers];
    //Tab should only be greater than views when testing and switching between a target with more tabs than another
    if (tab >= (NSInteger)[viewControllers count])
    {
        tab = 0;
    }
    
    UIViewController *viewController = [viewControllers objectAtIndex:tab];
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationViewController = (UINavigationController *)viewController;
        UIViewController *visibleViewController = [navigationViewController visibleViewController];
        
        [self populateViewController:visibleViewController];
    }
    
    [[self tabBarController] setSelectedIndex:tab];
}


#pragma mark -
#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{    
    [[self window] addSubview:[[self tabBarController] view]];
    [[self window] makeKeyAndVisible];
    
    [self restore];
}

//applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application
{    
    NSError *error;
    if (propertyObjectContext_ != nil)
    {
        if ([[self propertyObjectContext] hasChanges] && ![[self propertyObjectContext] save:&error])
        {
            // Handle error
            DebugLog(@"Error when saving context in application will terminate.");
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        } 
    }
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger tab = 0;
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
            tab = 0;
        }
        //If the visibile view controller is a Property History view controller...
        else if ([visibleViewController isKindOfClass:[PropertyHistoryViewController class]])
        {
            tab = 1;
        }
        //If the visibile view controller is a Property Favorites view controller...
        else if ([visibleViewController isKindOfClass:[PropertyFavoritesViewController class]])
        {
            tab = 2;
        }
#ifdef HOME_FINDER
        //If the visible view controller is a Mortgage Criteria view controller...
        else if ([visibleViewController isKindOfClass:[MortgageCriteriaViewController class]])
        {
            tab = 3;
        }
#endif
        
        [self populateViewController:visibleViewController];
    }
    
    //Saves the selected tab
    [[NSUserDefaults standardUserDefaults] setInteger:tab forKey:kSavedTab];
}

- (void)populateViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[PropertyStatesViewController class]])
    {
        PropertyStatesViewController *statesViewController = (PropertyStatesViewController *)viewController;
        [statesViewController setPropertyObjectContext:[self propertyObjectContext]];
        [statesViewController setGeographyObjectContext:[self geographyObjectContext]];
    }
    else if ([viewController isKindOfClass:[PropertyHistoryViewController class]])
    {
        PropertyHistoryViewController *historyViewController = (PropertyHistoryViewController *)viewController;
        [historyViewController setPropertyObjectContext:[self propertyObjectContext]];
    }
    else if ([viewController isKindOfClass:[PropertyFavoritesViewController class]])
    {
        PropertyFavoritesViewController *favoritesViewController = (PropertyFavoritesViewController *)viewController;
        //History will be nil the first time initializing the view controller
        //This check avoids an unnecessary fetch
        if ([favoritesViewController history] == nil)
        {
            PropertyHistory *history = [PropertyFavoritesViewController favoriteHistoryFromContext:[self propertyObjectContext]];
            [favoritesViewController setHistory:history];
        }
    }
#ifdef HOME_FINDER
    else if ([viewController isKindOfClass:[MortgageCriteriaViewController class]])
    {
        
    }
#endif
    
    //Restores view
    if([viewController conformsToProtocol:@protocol(SaveAndRestoreProtocol)])
    {
        [(id<SaveAndRestoreProtocol>)viewController restore];
    }
}

@end
