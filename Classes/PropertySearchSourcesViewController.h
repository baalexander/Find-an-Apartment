#import <UIKit/UIKit.h>

#import "PropertyCriteria.h"


@interface PropertySearchSourcesViewController : UITableViewController
{
    @private
        PropertyCriteria *criteria_;
        NSArray *choices_;
}

@property (nonatomic, retain) PropertyCriteria *criteria;

@end
