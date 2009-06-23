@class PropertyStatesViewController;

@interface FindAnApartmentAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
    @private
        UIWindow *window_;
        UITabBarController *tabBarController_;
        PropertyStatesViewController *statesViewController_;
    
        //Main Core Data stack
        NSManagedObjectModel *mainObjectModel_;
        NSManagedObjectContext *mainObjectContext_;
        NSPersistentStoreCoordinator *mainStoreCoordinator_;

        //Geography Core Data stack
        NSManagedObjectModel *geographyObjectModel_;
        NSManagedObjectContext *geographyObjectContext_;
        NSPersistentStoreCoordinator *geographyStoreCoordinator_;        
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PropertyStatesViewController *statesViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *mainObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *mainStoreCoordinator;

@property (nonatomic, retain, readonly) NSManagedObjectModel *geographyObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *geographyStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end

