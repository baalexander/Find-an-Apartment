#import "PropertyMapViewController.h"

#import "PropertyFavoritesViewController.h"
#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"
#import "PropertyListAndMapConstants.h"
#import "UrlUtil.h"
#import "PropertyGeocoder.h"


@interface PropertyMapViewController ()
@property (nonatomic, retain) NSArray *properties;
@property (nonatomic, retain) NSMutableArray *geocodedProperties;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) NSInteger selectedIndex;
- (void)geocodeProperties:(NSArray *)properties;
- (void)placeGeocodedPropertyOnMap:(PropertySummary *)property withIndex:(NSInteger)index;
@end


@implementation PropertyMapViewController

@synthesize properties = properties_;
@synthesize geocodedProperties = geocodedProperties_;
@synthesize history = history_;
@synthesize summary = summary_;
@synthesize mapView = mapView_;
@synthesize isCancelled = isCancelled_;
@synthesize isFromFavorites = isFromFavorites_;
@synthesize selectedIndex = selectedIndex_;


#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        //Default is NOT from Favorites
        [self setIsFromFavorites:NO];
        [self setIsCancelled:NO];
    }
    
    return self;
}

- (void)dealloc
{
    [mapView_ release];
    [properties_ release];
    [geocodedProperties_ release];
    [history_ release];
    [summary_ release];
 
    [super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
//    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
//    
//    //Bring up list view. Releases this view.
//    if ([segmentedControl selectedSegmentIndex] == kListItem)
//    {
//        if ([self isFromFavorites])
//        {
//            PropertyFavoritesViewController *favoritesViewController = [[PropertyFavoritesViewController alloc] initWithNibName:@"PropertyFavoritesView" bundle:nil];
//            [favoritesViewController setHistory:[self history]];
//            
//            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
//            [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:favoritesViewController];
//            [favoritesViewController release];
//            [[self navigationController] setViewControllers:viewControllers animated:NO];
//            [viewControllers release];            
//        }
//        else
//        {
//            PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
//            [listViewController setHistory:[self history]];
//            
//            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
//            [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:listViewController];
//            [listViewController release];
//            [[self navigationController] setViewControllers:viewControllers animated:NO];
//            [viewControllers release];
//        }
//    }
}

- (IBAction)loadDetailsView:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self setSelectedIndex:[button tag]];
    PropertySummary *summary = [[self geocodedProperties] objectAtIndex:[self selectedIndex]];
    
    //Pushes the Details view controller with the summary
    PropertyDetailsViewController *detailsViewController = [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView" bundle:nil];
    [detailsViewController setDelegate:self];
    [detailsViewController setDetails:[summary details]];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
}

- (IBAction)loadGoogleMaps:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self setSelectedIndex:[button tag]];
    PropertySummary *summary = [[self geocodedProperties] objectAtIndex:[self selectedIndex]];
    NSString *location = [summary location];
    
    //Opens up location in Google Maps app
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://maps.google.com/maps?q="];
    [url appendString:[UrlUtil encodeUrl:location]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    [url release];
}

- (void)geocodeProperties:(NSArray *)properties
{
    // Non-geocoded properties
    [self setProperties:properties];
    
    PropertyGeocoder *geocoder = [PropertyGeocoder sharedInstance];
    [geocoder setDelegate:self];
    [geocoder setProperties:properties];

    // There could be properties already geocoded, even though hasn't started
    // geocoding yet.
    NSMutableArray *geocodedProperties = 
        [[NSMutableArray alloc] initWithArray:[[geocoder geocodedProperties] allObjects]];
    [self setGeocodedProperties:geocodedProperties];
    [geocodedProperties release];
    
    // Maps all geocoded properties
    for (NSUInteger i = 0; i < [[self geocodedProperties] count]; i++)
    {
        PropertySummary *property = [[self geocodedProperties] objectAtIndex:i];
        [self placeGeocodedPropertyOnMap:property withIndex:i];
    }
    
    // Start geocoding
    [geocoder start];
}

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
            
            //If History is set, then coming from a List view controller and should load the Details view controller.
            if ([self history] != nil)
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

    if ([self history])
    {   
        // Segmented control
        NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
        [segmentOptions release];
        
        // Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
        [segmentedControl setSelectedSegmentIndex:kMapItem];
        [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        [segmentedControl release];
        [[self navigationItem] setRightBarButtonItem:segmentBarItem];
        [segmentBarItem release];
        
        NSArray *properties = [[[self history] summaries] allObjects];
        [self geocodeProperties:properties];
    }
    // Special set up when mapping a single property
    else if ([self summary])
    {
        [self setTitle:[[self summary] location]];
        
        NSArray *properties = [[NSArray alloc] initWithObjects:[self summary], nil];
        [self geocodeProperties:properties];
        [properties release];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setIsCancelled:YES];
    //Cancels any operations in the queue. This is for when pressing the back button and dismissing the view controller. This prevents the parser from still running and failing when calling its delegate.
    // TODO: How to cancel properly? Don't want to stop geocoding
    PropertyGeocoder *geocoder = [PropertyGeocoder sharedInstance];
    [geocoder setDelegate:nil];
}


//PropertyDetailsDelegate is used by Property Details view controller's segment control for previous/next
// TODO: Update delegate signatures, this isn't really a delegate right now
#pragma mark -
#pragma mark PropertyDetailsDelegate

- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details
{
    return [self selectedIndex];
}

- (NSInteger)detailsCount:(PropertyDetailsViewController *)details
{
    return [[self properties] count];
}

- (PropertyDetails *)detailsPrevious:(PropertyDetailsViewController *)details
{
    if ([self selectedIndex] > 0)
    {
        [self setSelectedIndex:[self selectedIndex] - 1];
    }
    else
    {
        [self setSelectedIndex:[self detailsCount:details] - 1];
    } 
    PropertySummary *summary = [[self properties] objectAtIndex:[self selectedIndex]];

    return [summary details];
}

- (PropertyDetails *)detailsNext:(PropertyDetailsViewController *)details
{
    if ([self selectedIndex] < [self detailsCount:details] - 1)
    {
        [self setSelectedIndex:[self selectedIndex] + 1];
    }
    else
    {
        [self setSelectedIndex:0];
    }
    PropertySummary *summary = [[self properties] objectAtIndex:[self selectedIndex]];
    
    return [summary details];
}


#pragma mark -
#pragma mark PropertyGeocoderDelegate

- (void)propertyGeocoder:(PropertyGeocoder *)geocoder didFindProperty:(PropertySummary *)summary
{
    [[self geocodedProperties] addObject:summary];
    
    [self placeGeocodedPropertyOnMap:summary withIndex:([[self geocodedProperties] count] - 1)];
}

- (void)propertyGeocoder:(PropertyGeocoder *)geocoder didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error mapping results" 
                                                         message:[error localizedDescription] 
                                                        delegate:self 
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];    
}

@end
