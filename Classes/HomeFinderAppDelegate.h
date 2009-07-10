#import "AppDelegate.h"

@interface HomeFinderAppDelegate : AppDelegate <UITabBarControllerDelegate>
{
    @private
        //Mortgage Core Data stack
        NSManagedObjectModel *mortgageObjectModel_;
        NSManagedObjectContext *mortgageObjectContext_;
        NSPersistentStoreCoordinator *mortgageStoreCoordinator_;    
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *mortgageStoreCoordinator;

@end

