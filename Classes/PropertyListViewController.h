#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "PropertyHistory.h"
#import "PropertyDetails.h"
#import "PropertySummary.h"
#import "XmlParser.h"


@interface PropertyListViewController : UITableViewController <ParserDelegate>
{
    //Determines if view controller is in the middle of a parsing operation
    BOOL isParsing_;
    
    XmlParser *parser_;
    
    //Core Data objects
    PropertyHistory *history_;
    PropertyDetails *details_;
    PropertySummary *summary_;
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
}

//Public property so History view controller can set
@property (nonatomic, retain) PropertyHistory *history;

- (void)parse:(NSURL *)url;
- (IBAction)changeView:(id)sender;

@end
