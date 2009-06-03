#import <UIKit/UIKit.h>

#import "PropertyCriteria.h"


@class InputRangeCell;
@class InputSimpleCell;

@interface PropertyCriteriaViewController : UITableViewController <UITextFieldDelegate>
{
    UITextField *currentTextField_;
    NSInteger selectedRow_;
    BOOL isEditingRow_;
    PropertyCriteria *criteria_;
    NSMutableArray *rowIds_;
    
    NSString *state_;
    NSString *city_;
    NSString *postalCode_;
    
    IBOutlet InputRangeCell *inputRangeCell_;
    IBOutlet InputSimpleCell *inputSimpleCell_;
}

@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postalCode;

@property (nonatomic, retain) InputRangeCell *inputRangeCell;
@property (nonatomic, retain) InputSimpleCell *inputSimpleCell;

@end
