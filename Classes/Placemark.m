#import "Placemark.h"


@implementation Placemark

@synthesize address = address_;
@synthesize coordinate = coordinate_;
@synthesize north = north_;
@synthesize east = east_;
@synthesize south = south_;
@synthesize west = west_;


- (id)init
{    
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [address_ release];
    
    [super dealloc];
}

@end
