#import "FindAnApartmentAppDelegate.h"

#import "PropertyStatesViewController.h"
#import "State.h"
#import "City.h"
#import "PostalCode.h"


@interface FindAnApartmentAppDelegate ()

@property (nonatomic, retain, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readwrite) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *geographyStoreCoordinator;

@end


@implementation FindAnApartmentAppDelegate

@synthesize window = window_;
@synthesize tabBarController = tabBarController_;
@synthesize statesViewController = statesViewController_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;
@synthesize geographyObjectContext = geographyObjectContext_;
@synthesize geographyStoreCoordinator = geographyStoreCoordinator_;



#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
//    //The lines below populate the geography.sql file with a few cities and zips
//    NSEntityDescription *stateEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"State"];
//    State *texas = [[State alloc] initWithEntity:stateEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [texas setName:@"Texas"];
//    [texas setAbbreviation:@"TX"];
//
//    NSEntityDescription *cityEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"City"];
//    City *austin = [[City alloc] initWithEntity:cityEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [austin setName:@"Austin"];
//    [austin setState:texas];
//    City *missouriCity = [[City alloc] initWithEntity:cityEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [missouriCity setName:@"Missouri City"];
//    [missouriCity setState:texas];
//    
//    NSEntityDescription *postalCodeEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"PostalCode"];
//    PostalCode *texasZip1 = [[PostalCode alloc] initWithEntity:postalCodeEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [texasZip1 setName:@"78701"];
//    [texasZip1 setCity:austin];
//    [texasZip1 setState:texas];
//    PostalCode *texasZip2 = [[PostalCode alloc] initWithEntity:postalCodeEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [texasZip2 setName:@"78703"];
//    [texasZip2 setCity:austin];
//    [texasZip2 setState:texas];    
//    PostalCode *texasZip3 = [[PostalCode alloc] initWithEntity:postalCodeEntity insertIntoManagedObjectContext:[self geographyObjectContext]];
//    [texasZip3 setName:@"77459"];
//    [texasZip3 setCity:missouriCity];
//    [texasZip3 setState:texas];
//    
//    [[self geographyObjectContext] save:nil];    
    [[self statesViewController] setManagedObjectContext:[self managedObjectContext]];
    [[self window] addSubview:[[self tabBarController] view]];
    [[self window] makeKeyAndVisible];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{	
    NSError *error;
    if (managedObjectContext_ != nil)
    {
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error])
        {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

- (void)dealloc
{
    [tabBarController_ release];
	[window_ release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [geographyObjectContext_ release];
    [geographyStoreCoordinator_ release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark main Core Data stack

//Main object context
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setManagedObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self managedObjectContext] setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    }
    
    return managedObjectContext_;
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

//Main persistent store coordinate
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ == nil)
    {	
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [self setPersistentStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        
        NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Find_an_Apartment.sqlite"]];
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            // Handle error
        }    
    }
	
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark geography Core Data stack

- (NSManagedObjectContext *)geographyObjectContext
{
    if (geographyObjectContext_ == nil)
    {
        NSManagedObjectContext *geographyObjectContext = [[NSManagedObjectContext alloc] init];
        [self setGeographyObjectContext:geographyObjectContext];
        [geographyObjectContext release];

        [[self geographyObjectContext] setPersistentStoreCoordinator:[self geographyStoreCoordinator]];
    }
    
    return geographyObjectContext_;
}

//Geographical data is stored in its own persistent storage
- (NSPersistentStoreCoordinator *)geographyStoreCoordinator
{
    if (geographyStoreCoordinator_ == nil)
    {	
        NSPersistentStoreCoordinator *geographyStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [self setGeographyStoreCoordinator:geographyStoreCoordinator];
        [geographyStoreCoordinator release];
        
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
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

@end

