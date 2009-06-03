@interface FindAnApartmentAppDelegate : NSObject <UIApplicationDelegate>
{
    @private
        UIWindow *window_;
        UITabBarController *tabBarController_;
        
        NSManagedObjectModel *managedObjectModel_;
        NSManagedObjectContext *managedObjectContext_;
        NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end

