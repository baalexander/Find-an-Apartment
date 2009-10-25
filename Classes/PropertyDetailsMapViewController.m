#import "PropertyDetailsMapViewController.h"

#import "Placemark.h"
#import "PropertyAnnotation.h"
#import "LocationParser.h"
#import "UrlUtil.h"


@interface PropertyDetailsMapViewController ()
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, assign, getter=isGeocoding) BOOL geocoding;
@property (nonatomic, retain) PropertySummary *property;
- (void)addPlacemarkWithAnimatedZoom:(BOOL)animation;
@end


@implementation PropertyDetailsMapViewController

@synthesize mapView = mapView_;
@synthesize geocoder = geocoder_;
@synthesize geocoding = geocoding_;
@synthesize property = property_;


#pragma mark -
#pragma mark PropertyDetailsMapViewController

- (void)dealloc
{
    [mapView_ release];
    [geocoder_ release];
    [property_ release];
    
    [super dealloc];
}

- (IBAction)loadInGoogleMaps:(id)sender
{
    // Opens up location in Google Maps app
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://maps.google.com/maps?q="];
    NSString *location = [[self property] location];
    [url appendString:[UrlUtil encodeUrl:location]];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [url release];
}

- (void)mapProperty:(PropertySummary *)property
{
    [self setProperty:property];
    
    // Property is already geocoded, add to map
    if ([[property longitude] doubleValue] != 0 && [[property latitude] doubleValue] != 0)
    {
        // Want to start the map right at the placemark and avoid unnecessary
        // zooming in processing
        [self addPlacemarkWithAnimatedZoom:NO];
    }
    // Need to geocode property
    else
    {
        [self setGeocoding:YES];
        
        // Create a Geocoder with the property's location
        Geocoder *geocoder = [[Geocoder alloc] initWithLocation:[[self property] location]];
        [self setGeocoder:geocoder];
        [geocoder release];
        
        [[self geocoder] setDelegate:self];
        [[self geocoder] start];
    }
}

- (void)addPlacemarkWithAnimatedZoom:(BOOL)animation
{
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [[[self property] longitude] doubleValue];
    coordinate.latitude = [[[self property] latitude] doubleValue];
    
    // Creates Placemark
    Placemark *placemark = [[Placemark alloc] init];
    [placemark setAddress:[[self property] location]];
    [placemark setCoordinate:coordinate];
    
    // Setup the pin to be placed on the map
    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithPlacemark:placemark];
    [placemark release];
    
    // Add pin to the map
    [[self mapView] addAnnotation:annotation];
    [annotation release];
    
    // Zoom out a bit
    MKCoordinateSpan span;
    span.longitudeDelta = 0.01;
    span.latitudeDelta = 0.01;
    
    // Center the map on the placemark
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    [[self mapView] setRegion:region animated:animation];
}

- (void)setGeocoding:(BOOL)geocoding
{
    geocoding_ = geocoding;
    
    // Updates the network activity indicator based on if geocoding
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:geocoding];
}

#pragma mark -
#pragma mark MKMapViewDelegate

// Create the annotations view for use when it appears on the screen
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *kPropertyPinId = @"PROPERTY_PIN_ID";
    
    // Create pins with buttons. Make sure a PropertyAnnotation so the current
    // location is still the "blue dot" pin.
    if ([annotation isMemberOfClass:[PropertyAnnotation class]])
    {
        PropertyAnnotation *propertyAnnotation = (PropertyAnnotation *)annotation;
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kPropertyPinId];
        
        // Create a new view if needed
        if (annotationView == nil)
        {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:propertyAnnotation reuseIdentifier:kPropertyPinId] autorelease];
            [annotationView setCanShowCallout:YES];
        }

        return annotationView;
    }
    
    return nil;
}


#pragma mark -
#pragma mark GeocoderDelegate

- (void)geocoder:(Geocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate
{
    // If cancel was called before this call back, stop all geocoding
    if (![self isGeocoding])
    {
        return;
    }
    
    [self setGeocoding:NO];
    
    // Sorry equator and Prime Meridian, no 0 coordinates allowed because
    // _usually_ a parsing or downloading mishap
    if (coordinate.longitude != 0 && coordinate.latitude != 0)
    {
        // Sets coordinate details
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [[self property] setLatitude:latitude];
        [latitude release];

        NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
        [[self property] setLongitude:longitude];
        [longitude release];
        
        // Map the geocoded property
        // Animate the zoom so the map doesn't abrubptly switch from world view
        // to the placemark
        [self addPlacemarkWithAnimatedZoom:YES];
        
        // Saves the geocoded property
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self property] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving geocoded property.");
        }
    }
}

- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error
{
    // If cancel was called before this call back, stop all geocoding
    if (![self isGeocoding])
    {
        return;
    }
    
    
    [self setGeocoding:NO];
    
    // TODO: Alert user of the error
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add Load in Google Maps button
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Load in Maps"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(loadInGoogleMaps:)];
    [[self navigationItem] setRightBarButtonItem:button];
    [button release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Cancels the geocoding operation, if any
    [[self geocoder] cancel];
    [self setGeocoding:NO];
}

@end
