#import "PropertyGeocoder.h"


@interface PropertyGeocoder ()
@property (nonatomic, assign, readwrite, getter=isQuerying) BOOL querying;
@property (nonatomic, retain) Geocoder *geocoder;
- (void)enqueueNextSummary;
@end


@implementation PropertyGeocoder

@synthesize delegate = delegate_;
@synthesize summaries = summaries_;
@synthesize querying = querying_;
@synthesize geocoder = geocoder_;


#pragma mark -
#pragma mark PropertyGeocoder

static PropertyGeocoder *propertyGeocoder_ = NULL;

+ (PropertyGeocoder *)sharedInstance
{
    @synchronized(self)
    {
        if (propertyGeocoder_ == NULL)
        {
            propertyGeocoder_ = [[self alloc] init];
        }
    }
    
    return (propertyGeocoder_);
}

// Yes it's a singleton right now, but it's good practice to treat the memory
// management like any other class.
- (void)dealloc
{
    [summaries_ release];
    [geocoder_ release];
    
    [super dealloc];
}

- (void)setSummaries:(NSSet *)summaries
{
    [summaries retain];
    [summaries_ release];
    summaries_ = summaries;
    
    // Setting the summaries stops the geocoding
    [self setQuerying:NO];
}

- (NSSet *)geocodedProperties
{
    NSMutableSet *geocodedProperties = [NSMutableSet set];
    
    for (PropertySummary *summary in [self summaries])
    {
        if ([summary longitude] != nil && [summary latitude] != nil)
        {
            [geocodedProperties addObject:summary];
        }
    }
    
    return geocodedProperties;
}

- (void)start
{
    [self setQuerying:YES];
    
    [self enqueueNextSummary];
}

- (void)enqueueNextSummary
{
    // Looks for next summary that has not been geocoded
    for (PropertySummary *summary in [self summaries])
    {
        // Checks if longitude and latitude already set. Ignores properties with
        // no location.
        if ([summary location] != nil
            && ([summary longitude] == nil || [summary latitude] == nil))
        {   
            // Create a Geocoder with the property's location
            Geocoder *geocoder = [[Geocoder alloc] initWithLocation:[summary location]];
            [self setGeocoder:geocoder];
            [geocoder release];
            
            [[self geocoder] setDelegate:self];
            [[self geocoder] start];
        }
    }
}

- (void)cancel
{
    // Set querying status to NO
    [self setQuerying:NO];
    
    // Cancels the geocoding process, if any
    [[self geocoder] cancel];
}


#pragma mark -
#pragma mark GeocoderDelegate

- (void)geocoder:(Geocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate
{
    
}

- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error
{
    
}

@end
