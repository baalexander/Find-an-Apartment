#import "UrlConstructor.h"

#import "Constants.h"
#import "UrlUtil.h"
#import "ApiKeys.h"
#import "NSString+Crypto.h"


@implementation UrlConstructor


#pragma mark -
#pragma mark UrlConstructor

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)apiKey
{
    // Gets timestamp as epoch
    NSDate *now = [[NSDate alloc] init];
    double seconds = [now timeIntervalSince1970];
    [now release];
    
    // Hashes timestamp and API key
    NSString *keyToHash = [[NSString alloc] initWithFormat:@"%d%@", (NSInteger)seconds, kAlexanderMobileApiKey];
    NSString *hash = [keyToHash sha1];
    [keyToHash release];
    
    return [NSString stringWithFormat:@"&timestamp=%d&api_key=%@", (NSInteger)seconds, hash];
}

- (NSString *)version
{
    return [NSString stringWithFormat:@"&version=%@", kAppVersion];
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

- (NSString *)parameter:(NSString *)param withValue:(NSString *)value
{
    if (value != nil && [value length] > 0)
    {
        return [NSString stringWithFormat:@"&%@=%@", param, [UrlUtil encodeUrl:value]];
    }
    else
    {
        return @"";
    }
}

- (NSString *)parameter:(NSString *)param withNumericValue:(NSNumber *)value
{
    if (value != nil)
    {        
        return [NSString stringWithFormat:@"&%@=%@", param, [value stringValue]];
    }
    else
    {
        return @"";
    }
}

@end
