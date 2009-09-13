#import <UIKit/UIKit.h>

#import "MortgageCriteria.h"
#import "XmlParser.h"
#import "ProvidedByZillowCell.h"


@interface MortgageResultsViewController : UITableViewController <ParserDelegate>
{
    @private
        NSOperationQueue *operationQueue_;
        BOOL isParsing_;
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
