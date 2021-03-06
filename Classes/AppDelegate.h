#import "SaveAndRestoreProtocol.h"

@class PropertyStatesViewController;

@interface AppDelegate : NSObject <SaveAndRestoreProtocol, UIApplicationDelegate>
{
    @protected
        UIWindow *window_;
        UITabBarController *tabBarController_;
        
        //Property Core Data stack
        NSManagedObjectModel *propertyObjectModel_;
        NSManagedObjectContext *propertyObjectContext_;
        NSPersistentStoreCoordinator *propertyStoreCoordinator_;
        
        //Geography Core Data stack
        NSManagedObjectModel *geographyObjectModel_;
        NSManagedObjectContext *geographyObjectContext_;
        NSPersistentStoreCoordinator *geographyStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *propertyObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *propertyObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *propertyStoreCoordinator;

@property (nonatomic, retain, readonly) NSManagedObjectModel *geographyObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *geographyObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *geographyStoreCoordinator;

+ (NSString *)applicationDocumentsDirectory;

@end

