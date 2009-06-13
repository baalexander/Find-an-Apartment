#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "PropertyHistory.h"
#import "PropertyDetails.h"
#import "PropertySummary.h"
#import "XmlParser.h"


@interface PropertyListViewController : UITableViewController <ParserDelegate>
{
    @private
        //Parsing objects
        XmlParser *parser_;
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
}

@property (nonatomic, retain) PropertyHistory *history;

- (void)parse:(NSURL *)url;
- (IBAction)changeView:(id)sender;

@end
