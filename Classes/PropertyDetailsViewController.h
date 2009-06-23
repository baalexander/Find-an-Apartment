#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyDetails.h"
#import "LocationCell.h"
#import "DescriptionCell.h"

@class PropertyDetailsViewController;

// Protocol for the PropertyDetails view controller to talk back to its delegate
@protocol PropertyDetailsDelegate <NSObject>
//Index of details in result list
- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details;
//Size of result list
- (NSInteger)detailsCount:(PropertyDetailsViewController *)details;
//Gets the previous detail
- (PropertyDetails *)detailsPrevious:(PropertyDetailsViewController *)details;
//Gets the next detail
- (PropertyDetails *)detailsNext:(PropertyDetailsViewController *)details;
@end


@interface PropertyDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    @private
        id <PropertyDetailsDelegate> delegate_;
    
        UITableView *tableView_;
    
        PropertyDetails *details_;
        NSMutableArray *sectionTitles_;
        NSMutableArray *sectionDetails_;
    
        IBOutlet LocationCell *locationCell_;
        IBOutlet DescriptionCell *descriptionCell_;
}

@property (nonatomic, assign) id<PropertyDetailsDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) LocationCell *locationCell;
@property (nonatomic, retain) DescriptionCell *descriptionCell;

- (IBAction)share:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
