#import "PropertyMapViewController.h"

#import "PropertyListAndMapConstants.h"
#import "Placemark.h"
#import "PropertyAnnotation.h"
#import "PropertySummary.h"
#import "LocationParser.h"


@interface PropertyMapViewController ()
@property (nonatomic, retain) PropertyCriteria *criteria;
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, assign, getter=isGeocoding) BOOL geocoding;
@property (nonatomic, assign, getter=isCentered) BOOL centered;
@end


@implementation PropertyMapViewController

@synthesize mapView = mapView_;
@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyDelegate = propertyDelegate_;
@synthesize criteria = criteria_;
@synthesize geocoder = geocoder_;
@synthesize geocoding = geocoding_;
@synthesize centered = centered_;


#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        [self setGeocoding:NO];
        [self setCentered:NO];
    }
    
    return self;
}

- (void)dealloc
{
    [mapView_ release];
    [criteria_ release];
    [geocoder_ release];
 
    [super dealloc];
}

- (IBAction)clickedButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [[self propertyDelegate] view:[self mapView] didSelectPropertyAtIndex:[button tag]];
}

- (void)addProperty:(PropertySummary *)property atIndex:(NSInteger)index
{
    // TODO: Implement
}

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index
{
    // Creates Placemark
    Placemark *placemark = [[Placemark alloc] init];
    [placemark setAddress:[property location]];
    
    // Adds coordinate
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [[property longitude] doubleValue];
    coordinate.latitude = [[property latitude] doubleValue];
    [placemark setCoordinate:coordinate];
    
    // Setup the pin to be placed on the map
    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithPlacemark:placemark];
    // Index is used to keep track of button pressings on the map and the
    // property they correspond to
    [annotation setIndex:index];
    
    // Add pin to the map
    [[self mapView] addAnnotation:annotation];
    [annotation release];
    
    // If the map is not already centered, center on this property
    if (![self isCentered])
    {
        [self setCentered:YES];
        
        [self centerOnCoordinate:coordinate];
    }
}

- (void)resetMap
{
    NSArray *annotations = [[self mapView] annotations];
    [[self mapView] removeAnnotations:annotations];
}

- (void)centerOnCriteria:(PropertyCriteria *)criteria
{
    [self setCriteria:criteria];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[criteria latitude] doubleValue];
    coordinate.longitude = [[criteria longitude] doubleValue];

    if (coordinate.latitude != 0 && coordinate.longitude != 0)
    {
        [self centerOnCoordinate:coordinate];
    }
    else
    {
        NSString *location = [LocationParser locationWithStreet:[criteria street]
                                                       withCity:[criteria city]
                                                      withState:[criteria state]
                                                 withPostalCode:[criteria postalCode]];

        [self setGeocoding:YES];
        
        // Create a Geocoder with the property's location
        Geocoder *geocoder = [[Geocoder alloc] initWithLocation:location];
        [self setGeocoder:geocoder];
        [geocoder release];
        
        [[self geocoder] setDelegate:self];
        [[self geocoder] start];
    }

}

- (void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setCentered:YES];
    
    // Add padding so the pins aren't on the very edge of the map
    MKCoordinateSpan span;
    span.longitudeDelta = kLongitudeDelta;
    span.latitudeDelta = kLatitudeDelta;
    
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    [[self mapView] setRegion:region animated:NO]; 
}


#pragma mark -
#pragma mark MKMapViewDelegate

// Create the annotations view for use when it appears on the screen
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
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
            
            // Create a button and add to the Annotation view
            UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [detailsButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [detailsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [annotationView setRightCalloutAccessoryView:detailsButton];
        }
        
        // The button tag maps to the property index
        // This identifies which property to load when the button is clicked
        UIButton *detailsButton = (UIButton *)[annotationView rightCalloutAccessoryView];
        [detailsButton setTag:[propertyAnnotation index]];
        
        [detailsButton addTarget:self
                          action:@selector(clickedButton:)
                forControlEvents:UIControlEventTouchUpInside];
        
        
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
        // Adds the coordinate to the Criteria
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
        [[self criteria] setLongitude:longitude];
        [longitude release];
        
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [[self criteria] setLatitude:latitude];
        [latitude release];
        
        // Saves the updated Criteria
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self criteria] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving criteria context.");
        }
        
        // Center the map
        [self centerOnCoordinate:coordinate];
    }
}

- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error
{
    [self setGeocoding:NO];
    
    // No need to alert user of error... for now
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
