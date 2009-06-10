#import "InputSimpleCell.h"


@implementation InputSimpleCell

@synthesize input = input_;


#pragma mark -
#pragma mark InputSimpleCell

- (void)dealloc
{
    [input_ release];
    
    [super dealloc];
}


@end
