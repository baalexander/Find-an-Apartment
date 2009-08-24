#import "PropertyAnnotation.h"


@implementation PropertyAnnotation

@synthesize placemark = placemark_;
@synthesize summaryIndex = summaryIndex_;


- (id)initWithPlacemark:(Placemark *)placemark
{
    if((self = [super init]))
    {
        [self setPlacemark:placemark];
    }

    return self;
}

- (void)dealloc
{
    [placemark_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return [[self placemark] coordinate];
}

- (NSString *)title
{
    //Gets everything preceeding the first comma. Hopefully the street or maybe the city.
    NSString *address = [[self placemark] address];
    NSArray *addressComponents = [address componentsSeparatedByString:@","];
    if ([addressComponents count] > 0)
    {
        return [addressComponents objectAtIndex:0];
    }
    else
    {
        return @"No address available";
    }
}

@end
