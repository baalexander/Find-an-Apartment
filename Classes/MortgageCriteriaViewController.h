#import <UIKit/UIKit.h>

#import "CriteriaViewController.h"
#import "MortgageCriteria.h"

@interface MortgageCriteriaViewController : CriteriaViewController
{
    @private
        //Mortgage Core Data stack
        NSManagedObjectModel *mortgageObjectModel_;
        NSManagedObjectContext *mortgageObjectContext_;
        NSPersistentStoreCoordinator *mortgageStoreCoordinator_;    
    
        MortgageCriteria *criteria_;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *mortgageStoreCoordinator;

@property (nonatomic, retain) MortgageCriteria *criteria;

@end
