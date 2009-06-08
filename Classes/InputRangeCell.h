#import <UIKit/UIKit.h>


@interface InputRangeCell : UITableViewCell
{
    IBOutlet UITextField *minRange_;
    IBOutlet UITextField *maxRange_;
}

@property (nonatomic, retain) UITextField *minRange;
@property (nonatomic, retain) UITextField *maxRange;

@end
