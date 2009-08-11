#import "LocationCell.h"

#import "LocationParser.h"


@implementation LocationCell

@synthesize addressLine1 = addressLine1_;
@synthesize addressLine2 = addressLine2_;


#pragma mark -
#pragma mark LocationCell

- (void)dealloc
{
    [addressLine1_ release];
    [addressLine2_ release];
    
    [super dealloc];
}

- (void)setLocation:(NSString *)location
{
    LocationParser *parser = [[LocationParser alloc] initWithLocation:location];
    NSString *street = [parser street];
    NSString *cityStateZip = [parser cityStateZip];
    [parser release];
    
    if ([street isEqual:@""])
    {
        [[self addressLine1] setText:@"No street provided"];
    }
    else
    {
        [[self addressLine1] setText:street];
    }
    
    if ([cityStateZip isEqual:@""])
    {
        [[self addressLine2] setText:@"No city or state provided"];
    }
    else
    {
        [[self addressLine2] setText:cityStateZip];
    }
    
    
}

+ (CGFloat)height
{
    return 62;
}

@end
