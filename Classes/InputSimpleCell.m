#import "InputSimpleCell.h"


@implementation InputSimpleCell

@synthesize input = input_;

- (void)dealloc
{
    [input_ release];
    
    [super dealloc];
}


@end
