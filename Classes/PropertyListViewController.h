#import <UIKit/UIKit.h>

#import "SummaryCell.h"
#import "PropertyDataSource.h"


@interface PropertyListViewController : UITableViewController
{    
    @private
        UITableView *tableView_;
        SummaryCell *summaryCell_;
        id <PropertyDataSource> propertyDataSource_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet SummaryCell *summaryCell;
@property (nonatomic, assign) IBOutlet id <PropertyDataSource> propertyDataSource;

@end
