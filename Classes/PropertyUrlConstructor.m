#import "PropertyUrlConstructor.h"

#import "PropertyCriteriaConstants.h"
#import "UrlUtil.h"


@interface PropertyUrlConstructor ()
@property (nonatomic, retain) PropertyCriteria *criteria;
- (NSString *)bathrooms;
- (NSString *)bedrooms;
- (NSString *)keywords;
- (NSString *)location;
- (NSString *)price;
- (NSString *)saleType;
- (NSString *)searchSource;
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
    
    NSNumber *latitude = [[self criteria] latitude];
    NSNumber *longitude = [[self criteria] longitude];
    if (latitude != nil && [latitude doubleValue] != 0
        && longitude != nil && [longitude doubleValue] != 0)
    {
        [location appendFormat:@"&latitude=%@", [UrlUtil encodeUrl:[latitude stringValue]]];
        [location appendFormat:@"&longitude=%@", [UrlUtil encodeUrl:[longitude stringValue]]];
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
#ifdef HOME_FINDER
    return @"&sale_type=for_sale";
#else
    return @"&sale_type=for_rent";
#endif
}

- (NSString *)searchSource
{
    NSString *choice = [[self criteria] searchSource];
    
    if ([choice isEqual:kPropertyCriteriaTrulia])
    {
        return @"&search_source=trulia";
    }
    //Default search source is Google Base
    else
    {
        return @"&search_source=google_base";
    }
}

- (NSString *)sortBy
{
    NSString *choice = [[self criteria] sortBy];
    
    if ([choice isEqual:kPropertyCriteriaSortByPriceAscending])
    {
        return @"&sort_by=price&sort_order=ascending";
    }
    else if ([choice isEqual:kPropertyCriteriaSortByPriceDescending])
    {
        return @"&sort_by=price&sort_order=descending";
    }
    else if ([choice isEqual:kPropertyCriteriaSortByBestMatch])
    {
        return @"&sort_by=best_match&sort_order=ascending";
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
    NSString *baseUrl = @"http://www.alexandermobile.com/real_estate/properties/view.xml?";
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
    [mutableUrl appendString:[self searchSource]];
    [mutableUrl appendString:[self version]];
    [mutableUrl appendString:[self apiKey]];
    
    NSURL *url = [[[NSURL alloc] initWithString:mutableUrl] autorelease];
    DebugLog(@"URL:%@", url);
    [mutableUrl release];
    
    return url;
}

@end
