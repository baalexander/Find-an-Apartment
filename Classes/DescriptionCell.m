#import "DescriptionCell.h"


@implementation DescriptionCell

@synthesize textView = textView_;


#pragma mark -
#pragma mark DescriptionCell

- (void)dealloc
{
    [textView_ release];
    
    [super dealloc];
}

+ (CGFloat)height
{
    return 184;
}

@end
