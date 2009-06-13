#import <UIKit/UIKit.h>


@interface SummaryCell : UITableViewCell
{
    @private
        IBOutlet UILabel *title_;
        IBOutlet UILabel *subtitle_;
        IBOutlet UILabel *summary_;
        IBOutlet UILabel *price_;
}

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subtitle;
@property (nonatomic, retain) UILabel *summary;
@property (nonatomic, retain) UILabel *price;

@end
