#import "PropertyGeocodeParser.h"

#import "UrlUtil.h"


//Element name that separates each item in the XML results
static const char *kItemName = "Placemark";


@implementation PropertyGeocodeParser

@synthesize summary = summary_;

- (id)initWithSummary:(PropertySummary *)summary
{
    if ((self = [super init]))
    {
        [self setSummary:summary];
        
        //Sets URL
        NSString *encodedLocation = [UrlUtil encodeUrl:[summary location]];
        NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=xml&oe=utf8", encodedLocation];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        [urlString release];
        [self setUrl:url];
        [url release];
        
        //Sets delimieter
        [self setItemDelimiter:kItemName];
    }
    
    return self;
}

- (void)dealloc
{
    [summary_ release];
    
    [super dealloc];
}

@end
