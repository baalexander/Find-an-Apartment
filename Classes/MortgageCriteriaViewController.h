#import <UIKit/UIKit.h>


@interface MortgageCriteriaViewController : UITableViewController <UITextFieldDelegate>
{
    @private
        UITextField *currentTextField_;
        NSInteger selectedRow_;
        NSArray *rowIds_;
}

@end
