#import <UIKit/UIKit.h>

#import "PropertyHistory.h"


@interface PropertyMapViewController : UIViewController
{
    @private
        PropertyHistory *history_;
}

@property (nonatomic, retain) PropertyHistory *history;

@end
