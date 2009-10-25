#import <UIKit/UIKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "MortgageCriteria.h"
#import "ProvidedByZillowCell.h"


@interface MortgageResultsViewController : UITableViewController <XmlParserDelegate>
{
    @private
        NSOperationQueue *operationQueue_;
        BOOL parsing_;
        NSMutableArray *loans_;
        NSMutableArray *sectionTitles_;
        NSMutableDictionary *loan_;
        MortgageCriteria *criteria_;
        IBOutlet ProvidedByZillowCell *providedByZillowCell_;
}

@property (nonatomic, retain) MortgageCriteria *criteria;
@property (nonatomic, retain) ProvidedByZillowCell *providedByZillowCell;

- (void)parse:(NSURL *)url;

@end
