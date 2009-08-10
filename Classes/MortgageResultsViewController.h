#import <UIKit/UIKit.h>

#import "MortgageCriteria.h"
#import "XmlParser.h"


@interface MortgageResultsViewController : UITableViewController <ParserDelegate>
{
    @private
        NSOperationQueue *operationQueue_;
        BOOL isParsing_;
        NSMutableArray *loans_;
        NSMutableArray *sectionTitles_;
        NSMutableDictionary *loan_;
        MortgageCriteria *criteria_;
}

@property (nonatomic, retain) MortgageCriteria *criteria;

- (void)parse:(NSURL *)url;

@end
