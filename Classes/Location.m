#import "Location.h"


@implementation Location

@synthesize coordinate = coordinate_;
@synthesize street = street_;
@synthesize postalCode = postalCode_;
@synthesize city = city_;
@synthesize state = state_;

- (id)init
{    
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [street_ release];
    [postalCode_ release];
    [city_ release];
    [state_ release];
    
    [super dealloc];
}

@end
