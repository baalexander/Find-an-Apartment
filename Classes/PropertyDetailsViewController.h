#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyDetails.h"
#import "LocationCell.h"


@interface PropertyDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    @private
        UITableView *tableView_;
    
        PropertyDetails *details_;
        NSMutableArray *sectionTitles_;
        NSMutableArray *sectionDetails_;
    
        IBOutlet LocationCell *locationCell_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) LocationCell *locationCell;

- (IBAction)share:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
