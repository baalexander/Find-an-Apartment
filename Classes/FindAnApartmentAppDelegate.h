@class PropertyStatesViewController;

@interface FindAnApartmentAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
    @private
        UIWindow *window_;
        UITabBarController *tabBarController_;
        PropertyStatesViewController *statesViewController_;
    
        //Shared Core Data stack
        NSManagedObjectModel *managedObjectModel_;
    
        //Main Core Data stack
        NSManagedObjectContext *mainObjectContext_;
        NSPersistentStoreCoordinator *mainStoreCoordinator_;

        //Geography Core Data stack
        NSManagedObjectContext *geographyObjectContext_;
        NSPersistentStoreCoordinator *geographyStoreCoordinator_;        
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PropertyStatesViewController *statesViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain, readonly) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *mainStoreCoordinator;

@property (nonatomic, retain, readonly) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *geographyStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end

