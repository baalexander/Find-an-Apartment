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
    
    IBOutlet InputRangeCell *inputRangeCell_;
    IBOutlet InputSimpleCell *inputSimpleCell_;
}

@property (nonatomic, retain) InputRangeCell *inputRangeCell;
@property (nonatomic, retain) InputSimpleCell *inputSimpleCell;

- (void)setState:(NSString *)state;
- (void)setCity:(NSString *)city;
- (void)setPostalCode:(NSString *)postalCode;
- (void)setCoordinates:(NSString *)coordinates;

@end
