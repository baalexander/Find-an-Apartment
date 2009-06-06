#import <UIKit/UIKit.h>

#import "PropertyDetails.h"


@interface PropertyDetailsViewController : UITableViewController
{
    PropertyDetails *details_;
    NSMutableArray *sectionTitles_;
    NSMutableArray *sectionDetails_;
}

@property (nonatomic, retain) PropertyDetails *details;

@end
