#import <UIKit/UIKit.h>

#import "MortgageCriteria.h"

@class InputRangeCell;
@class InputSimpleCell;

@interface MortgageCriteriaViewController : UITableViewController <UITextFieldDelegate>
{
    @private
        //Mortgage Core Data stack
        NSManagedObjectModel *mortgageObjectModel_;
        NSManagedObjectContext *mortgageObjectContext_;
        NSPersistentStoreCoordinator *mortgageStoreCoordinator_;    
    
        UITextField *currentTextField_;
        NSInteger selectedRow_;
        NSArray *rowIds_;

        MortgageCriteria *criteria_;
    
        IBOutlet InputRangeCell *inputRangeCell_;
        IBOutlet InputSimpleCell *inputSimpleCell_;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *mortgageStoreCoordinator;

@property (nonatomic, retain) MortgageCriteria *criteria;

@property (nonatomic, retain) InputRangeCell *inputRangeCell;
@property (nonatomic, retain) InputSimpleCell *inputSimpleCell;

@end
