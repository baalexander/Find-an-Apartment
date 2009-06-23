#import <UIKit/UIKit.h>

#import "PropertyHistory.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate>
{
    @private
        PropertyHistory *history_;
}

@property (nonatomic, retain) PropertyHistory *history;

@end
