#import "PropertyAnnotation.h"


@implementation PropertyAnnotation

@synthesize coordinate = coordinate_;
@synthesize address = address_;


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

@end
