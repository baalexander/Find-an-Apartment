#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "PropertyResultsDataSource.h"
#import "PropertyDetails.h"
#import "LocationCell.h"
#import "DescriptionCell.h"

#ifdef HOME_FINDER
#import "TruliaCopyrightCell.h"
#import "ProvidedByTruliaCell.h"
#endif


//@class PropertyDetailsViewController;
//@class WebViewController;
//
//// Protocol for the PropertyDetails view controller to talk back to its delegate
//@protocol PropertyDetailsDelegate <NSObject>
////Index of details in result list
//- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details;
////Size of result list
//- (NSInteger)detailsCount:(PropertyDetailsViewController *)details;
////Gets the previous detail
//- (PropertyDetails *)detailsPrevious:(PropertyDetailsViewController *)details;
////Gets the next detail
//- (PropertyDetails *)detailsNext:(PropertyDetailsViewController *)details;
//@end


@protocol PropertyDetailsDelegate

- (void)onDetailsClose;

@end

@interface PropertyDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    @private
        UITableView *tableView_;
		
		id delegate;
        id <PropertyResultsDataSource> propertyDataSource_;
        NSInteger propertyIndex_;
    
        PropertyDetails *details_;
        NSMutableArray *sectionTitles_;
        NSMutableArray *sectionDetails_;
    
        IBOutlet LocationCell *locationCell_;
        IBOutlet DescriptionCell *descriptionCell_;
        
        UIBarButtonItem *addToFavoritesButton_;
    
#ifdef HOME_FINDER
        IBOutlet TruliaCopyrightCell *truliaCopyrightCell_;
        IBOutlet ProvidedByTruliaCell *providedByTruliaCell_;
#endif
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id<PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) NSInteger propertyIndex;

@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) LocationCell *locationCell;
@property (nonatomic, retain) DescriptionCell *descriptionCell;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addToFavoritesButton;

@property (nonatomic, assign) id delegate;

#ifdef HOME_FINDER
@property (nonatomic, retain) TruliaCopyrightCell *truliaCopyrightCell;
@property (nonatomic, retain) ProvidedByTruliaCell *providedByTruliaCell;
#endif

- (IBAction)share:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
