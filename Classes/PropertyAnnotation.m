#import "PropertyAnnotation.h"

#import "PropertySummary.h"


@implementation PropertyAnnotation

@synthesize coordinate = coordinate_;
@synthesize address = address_;
@synthesize summary = summary_;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
    if((self = [super init]))
    {
        coordinate_ = coord;
    }
    return self;
}

- (NSString *)title
{
    return [self address];
}

- (void)dealloc
{
    [address_ release];
    [summary_ release];
    
    [super dealloc];
}

@end
