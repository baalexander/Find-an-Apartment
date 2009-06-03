#import "InputRangeCell.h"


@implementation InputRangeCell

@synthesize minRange = minRange_;
@synthesize maxRange = maxRange_;

- (void)dealloc
{
    [minRange_ release];
    [maxRange_ release];

    [super dealloc];
}


@end
