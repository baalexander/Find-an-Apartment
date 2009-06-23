#import <UIKit/UIKit.h>


@interface DescriptionCell : UITableViewCell
{
    @private
        IBOutlet UITextView *textView_;
}

@property (nonatomic, retain) UITextView *textView;

+ (CGFloat)height;

@end
