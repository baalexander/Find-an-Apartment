#import "PropertyMapViewController.h"

#import "PropertyFavoritesViewController.h"
#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"
#import "PropertyListAndMapConstants.h"
#import "UrlUtil.h"
#import "LocationParser.h"


@interface PropertyMapViewController ()
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, retain) Geocoder *geocoder;
@end


@implementation PropertyMapViewController

@synthesize mapView = mapView_;
@synthesize summary = summary_;
@synthesize isCancelled = isCancelled_;
@synthesize propertyDataSource = propertyDataSource_;
@synthesize geocoder = geocoder_;


#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        [self setIsCancelled:NO];
    }
    
    return self;
}

- (void)dealloc
{
    [mapView_ release];
    [summary_ release];
    [geocoder_ release];
 
    [super dealloc];
}

- (IBAction)loadDetailsView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PropertySummary *property = [[self propertyDataSource] propertyAtIndex:[button tag]];
    
    //Pushes the Details view controller with the summary
    PropertyDetailsViewController *detailsViewController =
        [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView"
                                                        bundle:nil];
    //[detailsViewController setDelegate:self];
    [detailsViewController setDetails:[property details]];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
}

- (IBAction)loadGoogleMaps:(id)sender
{
//    UIButton *button = (UIButton *)sender;
//    PropertySummary *summary = [[self geocodedProperties] objectAtIndex:[button tag]];
//    NSString *location = [summary location];
//    
//    //Opens up location in Google Maps app
//    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://maps.google.com/maps?q="];
//    [url appendString:[UrlUtil encodeUrl:location]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    [url release];
}

//- (void)geocodeProperties:(NSArray *)properties
//{
//    // Non-geocoded properties
//    [self setProperties:properties];
//    
//    PropertyGeocoder *geocoder = [PropertyGeocoder sharedInstance];
//    [geocoder setDelegate:self];
//    [geocoder setProperties:properties];
//
//    // There could be properties already geocoded, even though hasn't started
//    // geocoding yet.
//    NSMutableArray *geocodedProperties = 
//        [[NSMutableArray alloc] initWithArray:[[geocoder geocodedProperties] allObjects]];
//    [self setGeocodedProperties:geocodedProperties];
//    [geocodedProperties release];
//    
//    // Maps all geocoded properties
//    for (NSUInteger i = 0; i < [[self geocodedProperties] count]; i++)
//    {
//        PropertySummary *property = [[self geocodedProperties] objectAtIndex:i];
//        [self placeGeocodedPropertyOnMap:property withIndex:i];
//    }
//    
//    // Start geocoding
//    [geocoder start];
//}

- (void)placeGeocodedPropertyOnMap:(PropertySummary *)property withIndex:(NSInteger)index
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
}

- (void)centerOnCriteria:(PropertyCriteria *)criteria
{
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
    // Add padding so the pins aren't on the very edge of the map
    MKCoordinateSpan span;
    span.longitudeDelta = kLongitudeDelta;
    span.latitudeDelta = kLatitudeDelta;
    
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    [[self mapView] setRegion:region animated:YES]; 
}


#pragma mark -
#pragma mark MKMapViewDelegate

// Create the annotations view for use when it appears on the screen
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //Create pins with buttons. Make sure a PropertyAnnotation so the current location is still the "blue dot" pin.
    if ([annotation isMemberOfClass:[PropertyAnnotation class]])
    {
        PropertyAnnotation *propertyAnnotation = (PropertyAnnotation *)annotation;
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kPropertyPinId];
            
        // If we have to, create a new view
        if (annotationView == nil)
        {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:propertyAnnotation reuseIdentifier:kPropertyPinId] autorelease];
            [annotationView setCanShowCallout:YES];

            UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [detailsButton setTag:[propertyAnnotation index]];
            [detailsButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [detailsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [annotationView setRightCalloutAccessoryView:detailsButton];
            
            //If Property Data Source is set, then coming from a List view controller and should load the Details view controller.
            if ([self propertyDataSource] != nil)
            {
                [detailsButton addTarget:self action:@selector(loadDetailsView:) forControlEvents:UIControlEventTouchUpInside];
            }
            //If History is not set, then coming from Details view controller. Pressing button should load in Google Maps.
            else
            {
                [detailsButton addTarget:self action:@selector(loadGoogleMaps:) forControlEvents:UIControlEventTouchUpInside];
            }        
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    // Special set up when mapping a single property
//    if ([self summary])
//    {
//        [self setTitle:[[self summary] location]];
//        
//        NSArray *properties = [[NSArray alloc] initWithObjects:[self summary], nil];
//        [self geocodeProperties:properties];
//        [properties release];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setIsCancelled:YES];
}


#pragma mark -
#pragma mark GeocoderDelegate

- (void)geocoder:(Geocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate
{
//    // If cancel was called before this call back, stop all processing
//    if (![self isQuerying])
//    {
//        return;
//    }
    
    // Sorry equator and Prime Meridian, no 0 coordinates allowed because
    // _usually_ a parsing or downloading mishap
    if (coordinate.longitude != 0 && coordinate.latitude != 0)
    {
        [self centerOnCoordinate:coordinate];
    }
}

- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error
{
//    // If cancel was called before this call back, stop all processing
//    if (![self isQuerying])
//    {
//        return;
//    }
//    
//    if ([self delegate] != nil)
//    {
//        [[self delegate] propertyGeocoder:self didFailWithError:error];
//    }
}

@end
