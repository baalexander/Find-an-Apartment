#import <UIKit/UIKit.h>


@class InputRangeCell;
@class InputSimpleCell;

@interface CriteriaViewController : UITableViewController <UITextFieldDelegate>
{
    @private
        UITextField *currentTextField_;
        NSInteger selectedRow_;
        NSArray *rowIds_;
        
        IBOutlet InputRangeCell *inputRangeCell_;
        IBOutlet InputSimpleCell *inputSimpleCell_;
}

@property (nonatomic, retain) InputRangeCell *inputRangeCell;
@property (nonatomic, retain) InputSimpleCell *inputSimpleCell;

@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, retain) NSArray *rowIds;

- (InputRangeCell *)inputRangeCellWithMin:(NSNumber *)min withMax:(NSNumber *)max;
- (InputSimpleCell *)inputSimpleCellWithText:(NSString *)text;
- (UITableViewCell *)simpleCellWithText:(NSString *)text withDetail:(NSString *)detailText;
- (UITableViewCell *)buttonCellWithText:(NSString *)text;

@end
