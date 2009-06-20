#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyDetails.h"


@interface PropertyDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    @private
        UITableView *tableView_;
    
        PropertyDetails *details_;
        NSMutableArray *sectionTitles_;
        NSMutableArray *sectionDetails_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) PropertyDetails *details;

- (IBAction)share:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
