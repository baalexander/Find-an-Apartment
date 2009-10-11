#import "Geocoder.h"
#import "GeocoderConstants.h"
#import "UrlUtil.h"


@interface Geocoder ()
@property (nonatomic, assign, readwrite, getter=isQuerying) BOOL querying;
@property (nonatomic, copy, readwrite) NSString *location;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end

@implementation Geocoder

@synthesize delegate = delegate_;
@synthesize querying = querying_;
@synthesize location = location_;
@synthesize coordinate = coordinate_;
@synthesize operationQueue = operationQueue_;


#pragma mark -
#pragma mark Geocoder

- (id)initWithLocation:(NSString *)location
{
    if ((self = [super init]))
    {
        [self setQuerying:NO];
        [self setLocation:location];
    }
    
    return self;    
}

- (void)dealloc
{
    [location_ release];
    
    [super dealloc];
}

- (void)start
{
    [self setQuerying:YES];
    
    // Add the Parser to an operation queue for background processing (works on 
    // a separate thread)
    XmlParser *parser = [[XmlParser alloc] init];
    [parser setDelegate:self];
    
    // Sets item delimiter for the Xml results
    [parser setItemDelimiter:kGeocoderItemDelimiter];
    
    // Sets URL
    NSString *encodedLocation = [UrlUtil encodeUrl:[self location]];
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=xml&oe=utf8", encodedLocation];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [urlString release];
    [parser setUrl:url];
    [url release];    
    
    // Begins geocoding operation by making the API request then parsing the 
    // results
    [[self operationQueue] addOperation:parser];
    [parser release];
}

- (void)cancel
{
    // Set querying status to NO
    [self setQuerying:NO];
    
    // Cancels Xml Parser
    [[self operationQueue] cancelAllOperations];
}

#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    // If cancel was called before this call back, stop all processing
    if (![self isQuerying])
    {
        return;
    }
    
    [self setQuerying:NO];
    
    // Return the geocoded coordinate to the delegate
    if ([self coordinate].latitude != 0 && [self coordinate].longitude != 0)
    {
        [[self delegate] geocoder:self didFindCoordinate:[self coordinate]];
    }
    else
    {
        // TODO: Call delegate with error about not finding the coordinates
        // [[self delegate] geocoder:self didFailWithError:error];
    }
}

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    // If cancel was called before this call back, stop all processing
    if (![self isQuerying])
    {
        return;
    }
    
    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    
    // Coordinate format is: <coordinates>-97.7743400,30.2797450,0</coordinates>
    // First param is longitude, second param is latitude, can ignore third 
    // param
    if ([elementName isEqual:@"coordinates"])
    {
        if (elementValue != nil)
        {
            NSArray *coordinateComponents = [elementValue componentsSeparatedByString:@","];
            if ([coordinateComponents count] >= 2)
            {
                CLLocationCoordinate2D coordinate;
                coordinate.longitude = [[coordinateComponents objectAtIndex:0] doubleValue];
                coordinate.latitude = [[coordinateComponents objectAtIndex:1] doubleValue];
                
                [self setCoordinate:coordinate];
            }
        }
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    // Normally create the object to hold the parsed data
    // Currently nothing to do
}

- (void)parserDidEndItem:(XmlParser *)parser
{
    // Currently nothing to do
}

- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error
{
    [self setQuerying:NO];
    
    [[self delegate] geocoder:self didFailWithError:error];
}


@end
