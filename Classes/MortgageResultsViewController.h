#import <UIKit/UIKit.h>

#import "XmlParser.h"


@interface MortgageResultsViewController : UITableViewController <ParserDelegate>
{
    @private
        XmlParser *parser_;
        BOOL isParsing_;
        NSMutableArray *loans_;
        NSMutableArray *sectionTitles_;
        NSMutableDictionary *loan_;
}

- (void)parse:(NSURL *)url;

@end
