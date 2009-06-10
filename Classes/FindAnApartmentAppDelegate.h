@class PropertyStatesViewController;

@interface FindAnApartmentAppDelegate : NSObject <UIApplicationDelegate>
{
    @private
        UIWindow *window_;
        UITabBarController *tabBarController_;
        PropertyStatesViewController *statesViewController_;
    
        //Main Core Data stack
        NSManagedObjectModel *managedObjectModel_;
        NSManagedObjectContext *managedObjectContext_;
        NSPersistentStoreCoordinator *persistentStoreCoordinator_;

        //Geography Core Data stack
        NSManagedObjectContext *geographyObjectContext_;
        NSPersistentStoreCoordinator *geographyStoreCoordinator_;        
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PropertyStatesViewController *statesViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *geographyStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end

