#import "PropertyAnnotation.h"


@implementation PropertyAnnotation

@synthesize placemark = placemark_;
@synthesize summary = summary_;


- (id)initWithPlacemark:(Placemark *)placemark andSummary:(PropertySummary *)summary
{
    if((self = [super init]))
    {
        [self setPlacemark:placemark];
        [self setSummary:summary];
    }

    return self;
}

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

- (void)dealloc
{
    [placemark_ release];
    [summary_ release];
    
    [super dealloc];
}

@end
