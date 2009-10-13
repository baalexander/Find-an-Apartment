#import "PropertyGeocoder.h"


@interface PropertyGeocoder ()
@property (nonatomic, assign, readwrite, getter=isQuerying) BOOL querying;
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, retain) PropertySummary *property;
- (void)enqueueNextProperty;
- (void)geocodeProperty:(PropertySummary *)property;
@end


@implementation PropertyGeocoder

@synthesize delegate = delegate_;
@synthesize properties = properties_;
@synthesize property = property_;
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
    [properties_ release];
    [property_ release];
    [geocoder_ release];
    
    [super dealloc];
}

- (void)setProperties:(NSArray *)properties
{
    [properties retain];
    [properties_ release];
    properties_ = properties;
    
    // Setting the properties stops the geocoding
    [self setQuerying:NO];
}

- (NSSet *)geocodedProperties
{
    NSMutableSet *geocodedProperties = [NSMutableSet set];
    
    for (PropertySummary *property in [self properties])
    {
        if ([property longitude] != nil && [property latitude] != nil)
        {
            [geocodedProperties addObject:property];
        }
    }
    
    return geocodedProperties;
}

- (void)start
{
    [self setQuerying:YES];
    
    [self enqueueNextProperty];
}

- (void)enqueueNextProperty
{
    // Looks for next property that has not been geocoded
    BOOL foundUngeocodedProperty = NO;
    for (PropertySummary *property in [self properties])
    {
        // Checks if longitude and latitude already set. Ignores properties with
        // no location.
        if ([property location] != nil
            && ([property longitude] == nil || [property latitude] == nil))
        {
            // To prevent overloading map requests and getting errors from their
            // server, add a delay
            [self performSelector:@selector(geocodeProperty:)
                       withObject:property
                       afterDelay:0.150]; 
            
            // Only enqueue one property at a time
            foundUngeocodedProperty = YES;
            break;
        }
    }
    
    // Every property has been geocoded, saves the context and update status
    if (!foundUngeocodedProperty)
    {
        // Saves the context
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self property] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving property context in Property Geocoder's enqueue.");
        }
        
        // Updates the status
        [self setQuerying:NO];
    }
}

// Begins geocoding the next property
// Meant to be called as a selector with a delay to prevent flooding request to
// maps
- (void)geocodeProperty:(PropertySummary *)property
{
    // Needs to know which property to populate coordinate data with
    [self setProperty:property];
    
    // Create a Geocoder with the property's location
    Geocoder *geocoder = [[Geocoder alloc] initWithLocation:[property location]];
    [self setGeocoder:geocoder];
    [geocoder release];
    
    [[self geocoder] setDelegate:self];
    [[self geocoder] start];
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
    // If cancel was called before this call back, stop all processing
    if (![self isQuerying])
    {
        return;
    }
    
    // Sorry equator and Prime Meridian, no 0 coordinates allowed because
    // _usually_ a parsing or downloading mishap
    if (coordinate.longitude != 0 && coordinate.latitude != 0)
    {
        // Sets the coordinate data in the property
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
        [[self property] setLongitude:longitude];
        [longitude release];
        
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [[self property] setLatitude:latitude];
        [latitude release];
        
        // Saves the context
        // TODO: Only save every x number of times
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self property] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving property context in Property Geocoder's didFindCoordinate.");
        }
    }
    
    // Lets delegate know a new property has been geocoded
    if ([self delegate] != nil)
    {
        [[self delegate] propertyGeocoder:self didFindProperty:[self property]];
    }
    
    // Fetches next property to download
    [self enqueueNextProperty];
}

- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error
{
    // If cancel was called before this call back, stop all processing
    if (![self isQuerying])
    {
        return;
    }

    if ([self delegate] != nil)
    {
        [[self delegate] propertyGeocoder:self didFailWithError:error];
    }
}

@end
