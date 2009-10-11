#import "PropertyGeocoder.h"


@interface PropertyGeocoder ()
@property (nonatomic, assign, readwrite, getter=isQuerying) BOOL querying;
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, retain) PropertySummary *summary;
- (void)enqueueNextProperty;
- (void)geocodeProperty:(PropertySummary *)summary;
@end


@implementation PropertyGeocoder

@synthesize delegate = delegate_;
@synthesize summaries = summaries_;
@synthesize summary = summary_;
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
    [summary_ release];
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
    
    [self enqueueNextProperty];
}

- (void)enqueueNextProperty
{
    // Looks for next summary that has not been geocoded
    BOOL foundUngeocodedProperty = NO;
    for (PropertySummary *summary in [self summaries])
    {
        // Checks if longitude and latitude already set. Ignores properties with
        // no location.
        if ([summary location] != nil
            && ([summary longitude] == nil || [summary latitude] == nil))
        {
            // To prevent overloading map requests and getting errors from their
            // server, add a delay
            [self performSelector:@selector(geocodeProperty:)
                       withObject:summary
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
        NSManagedObjectContext *managedObjectContext = [[self summary] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving summary context in Property Geocoder's enqueueNextSummary.");
        }
        
        // Updates the status
        [self setQuerying:NO];
    }
}

// Begins geocoding the next property
// Meant to be called as a selector with a delay to prevent flooding request to
// maps
- (void)geocodeProperty:(PropertySummary *)summary
{
    // Needs to know which summary to populate coordinate data with
    [self setSummary:summary];
    
    // Create a Geocoder with the property's location
    Geocoder *geocoder = [[Geocoder alloc] initWithLocation:[summary location]];
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
        [[self summary] setLongitude:longitude];
        [longitude release];
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [[self summary] setLatitude:latitude];
        [latitude release];
        
        // Saves the context
        // TODO: Only save every x number of times
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self summary] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving summary context in Property Geocoder's didFindCoordinate.");
        }
    }
    
    // Lets delegate know a new property has been geocoded
    if ([self delegate] != nil)
    {
        [[self delegate] propertyGeocoder:self didFindProperty:[self summary]];
    }
    
    // Fetches next summary to download
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
