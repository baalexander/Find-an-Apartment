#import <UIKit/UIKit.h>

#import "SummaryCell.h"
#import "PropertyResultsDelegate.h"
#import "PropertyResultsDataSource.h"


@interface PropertyListViewController : UITableViewController
{    
    @private
        UITableView *tableView_;
        SummaryCell *summaryCell_;
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet SummaryCell *summaryCell;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;

- (void)deselectRow;

@end
