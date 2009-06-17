#import <UIKit/UIKit.h>

#import "PropertyDetails.h"


@interface PropertyDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    @private
        PropertyDetails *details_;
        NSMutableArray *sectionTitles_;
        NSMutableArray *sectionDetails_;
}

@property (nonatomic, retain) PropertyDetails *details;

- (IBAction)share:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
