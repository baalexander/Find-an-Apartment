#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "PropertyHistory.h"
#import "PropertyDetails.h"
#import "PropertySummary.h"
#import "XmlParser.h"
#import "SummaryCell.h"
#import "PropertyDetailsViewController.h"


@interface PropertyListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ParserDelegate, PropertyDetailsDelegate>
{    
    @private
        UITableView *tableView_;

        //Queues parsing thread
        NSOperationQueue *operationQueue_;
        //Counter for keeping track of distance. Assumes results always sorted by distance, so assigns an incrementing value to each item it parses
        //Example: first property (assumed closest) has distance = 0, second property (assumed second closest) has distance = 1, and so on
        NSInteger distance_;
        //Determines if view controller is in the middle of a parsing operation
        BOOL isParsing_;
        
        //Core Data objects
        PropertyHistory *history_;
        PropertyDetails *details_;
        PropertySummary *summary_;
        NSFetchedResultsController *fetchedResultsController_;
    
        NSInteger selectedIndex_;

        IBOutlet SummaryCell *summaryCell_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) SummaryCell *summaryCell;
//This is "public" since needs to be inherited by Favorites. Would be protected if such a thing existed.
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

- (void)parse:(NSURL *)url;
- (IBAction)changeView:(id)sender;

@end
