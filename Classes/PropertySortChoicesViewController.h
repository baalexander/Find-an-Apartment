#import <UIKit/UIKit.h>

#import "PropertyCriteria.h"


@interface PropertySortChoicesViewController : UITableViewController
{
    @private
        PropertyCriteria *criteria_;
        NSArray *choices_;
}

@property (nonatomic, retain) PropertyCriteria *criteria;

@end
