#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "PropertyHistory.h"
#import "PropertyDetails.h"
#import "PropertySummary.h"
#import "XmlParser.h"


@interface PropertyListViewController : UITableViewController <ParserDelegate>
{
    XmlParser *parser_;
    
    //Core Data objects
    PropertyHistory *history_;
    PropertyDetails *details_;
    PropertySummary *summary_;
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
}

- (void)parse:(NSURL *)url;
- (IBAction) changeView:(id)sender;

@end
