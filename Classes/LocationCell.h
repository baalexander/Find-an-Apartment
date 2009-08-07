#import <UIKit/UIKit.h>


@interface LocationCell : UITableViewCell
{
    IBOutlet UILabel *addressLine1_;
    IBOutlet UILabel *addressLine2_;
}

@property (nonatomic, retain) UILabel *addressLine1;
@property (nonatomic, retain) UILabel *addressLine2;

+ (CGFloat)height;
- (void)setLocation:(NSString *)location;

@end
