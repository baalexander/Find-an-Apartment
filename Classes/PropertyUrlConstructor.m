#import "PropertyUrlConstructor.h"

#import "PropertyCriteriaConstants.h"
#import "UrlUtil.h"


@interface PropertyUrlConstructor ()
@property (nonatomic, retain) PropertyCriteria *criteria;
- (NSString *)deviceParams;
- (NSString *)bathrooms;
- (NSString *)bedrooms;
- (NSString *)keywords;
- (NSString *)location;
- (NSString *)price;
- (NSString *)rangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units;
- (NSString *)saleType;
- (NSString *)sortBy;
- (NSString *)squareFeet;
@end


@implementation PropertyUrlConstructor

@synthesize criteria = criteria_;


#pragma mark -
#pragma mark PropertyUrlConstructor

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}


- (void)dealloc
{
    [criteria_ release];
    
    [super dealloc];
}

- (NSString *)deviceParams
{
    NSMutableString *url = [NSMutableString string];
    //Assumes deviceParams is first set of params for URL so does not prepend with '&'
    [url appendString:@"device_brand=Apple"];
    [url appendFormat:@"&device_model=%@", [UrlUtil encodeUrl:[UIDevice currentDevice].model]];
    [url appendFormat:@"&device_serial_number=%@", [UrlUtil encodeUrl:[UIDevice currentDevice].uniqueIdentifier]];
    [url appendFormat:@"&system_name=%@", [UrlUtil encodeUrl:[UIDevice currentDevice].systemName]];
    [url appendFormat:@"&system_version=%@", [UrlUtil encodeUrl:[UIDevice currentDevice].systemVersion]];
    
    return url;
}

- (NSString *)rangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units
{
     NSMutableString *range = [NSMutableString string];
    
    if (min != nil && [min integerValue] > 0)
    {
        [range appendFormat:@"&min_%@=%@", units, [min stringValue]];
    }
    
    if (max != nil && [max integerValue] > 0)
    {
        [range appendFormat:@"&max_%@=%@", units, [max stringValue]];
    }
    
    return range;   
}

- (NSString *)bathrooms
{
    return [self rangeWithMin:[[self criteria] minBathrooms] 
                      withMax:[[self criteria] maxBathrooms] 
                    withUnits:@"bathrooms"];
}

- (NSString *)bedrooms
{
    return [self rangeWithMin:[[self criteria] minBedrooms] 
                      withMax:[[self criteria] maxBedrooms] 
                    withUnits:@"bedrooms"];
}

- (NSString *)keywords
{
    NSString *keywords = [[self criteria] keywords];
    if (keywords == nil || [keywords length] == 0)
    {
        return @"";
    }
    
    return [NSString stringWithFormat:@"&keywords=%@", [UrlUtil encodeUrl:keywords]];
}

- (NSString *)location
{
    NSMutableString *location = [NSMutableString string];
    
    NSString *postalCode = [[self criteria] postalCode];
    if (postalCode != nil && [postalCode length] > 0)
    {
        [location appendFormat:@"&postal_code=%@", [UrlUtil encodeUrl:postalCode]];
    }
    
    NSString *city = [[self criteria] city];
    if (city != nil && [city length] > 0)
    {
        [location appendFormat:@"&city=%@", [UrlUtil encodeUrl:city]];
    }
    
    NSString *state = [[self criteria] state];
    if (state != nil && [state length] > 0)
    {
        [location appendFormat:@"&state=%@", [UrlUtil encodeUrl:state]];
    }
    
    NSString *street = [[self criteria] street];
    if (street != nil && [street length] > 0)
    {
        [location appendFormat:@"&street=%@", [UrlUtil encodeUrl:street]];
    }
    
    NSString *coordinates = [[self criteria] coordinates];
    if (coordinates != nil && [coordinates length] > 0)
    {
        [location appendFormat:@"&coordinates=%@", [UrlUtil encodeUrl:coordinates]];
    }
    
    return location;
}

- (NSString *)price
{
    return [self rangeWithMin:[[self criteria] minPrice]
                      withMax:[[self criteria] maxPrice]
                    withUnits:@"price"];
}

- (NSString *)saleType
{
    return @"&sale_type=for_rent";
}

- (NSString *)sortBy
{
    NSString *choice = [[self criteria] sortBy];
    
    if ([choice isEqual:kCriteriaSortByPriceAscending])
    {
        return @"&sort_by=age&sort_order=ascending";
    }
    else if ([choice isEqual:kCriteriaSortByPriceDescending])
    {
        return @"&sort_by=age&sort_order=descending";
    }
    //Default sort is distance
    else
    {
        return @"&sort_by=distance&sort_order=ascending";
    }
}

- (NSString *)squareFeet
{
    return [self rangeWithMin:[[self criteria] minSquareFeet]
                      withMax:[[self criteria] maxSquareFeet]
                    withUnits:@"square_feet"];
}

- (NSURL *)urlFromCriteria:(PropertyCriteria *)criteria
{
    [self setCriteria:criteria];
    
    //Creates base URL
    NSString *baseUrl = @"http://www.alexandermobile.com/real_estate_dev/properties/view.xml?";
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:baseUrl];
    
    //Appends device params
    [mutableUrl appendString:[self deviceParams]];
    
    //Appends fields from user input
    [mutableUrl appendString:[self location]];
    [mutableUrl appendString:[self keywords]];
    [mutableUrl appendString:[self price]];
    [mutableUrl appendString:[self squareFeet]];
    [mutableUrl appendString:[self bedrooms]];
    [mutableUrl appendString:[self bathrooms]];
    [mutableUrl appendString:[self sortBy]];
    [mutableUrl appendString:[self saleType]];
    
    NSURL *url = [[[NSURL alloc] initWithString:mutableUrl] autorelease];
    NSLog(@"URL:%@", url);
    [mutableUrl release];
    
    return url;
}

@end
