#import "PropertyMapViewController.h"

#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"
#import "JSON.h"


#define kMaxMapItems 25
//Segmented Control items. Eventually put in a constants file so List view controller does not have to have a duplicate.
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


@implementation PropertyMapViewController

@synthesize history = history_;
@synthesize address = address_;
@synthesize mapView = mapView_;


#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {

    }
    
    return self;
}

- (void)dealloc
{
    [history_ release];
    [mapView_ release];
    
    [super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    //Bring up list view. Releases this view.
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        //FIXME: What if called from the Favorites view controller? Then needs to load PropertyFavoritesView
        PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
        [listViewController setHistory:[self history]];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
        [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:listViewController];
        [listViewController release];
        [[self navigationController] setViewControllers:viewControllers animated:NO];
        [viewControllers release];
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Center the map based on the user's input
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self setMapView:mapView];
    [mapView release];
    [self.view addSubview:[self mapView]];
    
    if([self history])
    {
        //Segmented control
        NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
        [segmentOptions release];
        
        //Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
        [segmentedControl setSelectedSegmentIndex:kMapItem];
        [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        [segmentedControl release];
        [[self navigationItem] setRightBarButtonItem:segmentBarItem];
        [segmentBarItem release];
        
        [self centerMap];
    }
    else
    {
        [[self navigationItem] setTitle:[self address]];
        [self geocodePropertyFromAddress:[self address]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
}


//PropertyDetailsDelegate is used by Property Details view controller's segment control for previous/next
#pragma mark -
#pragma mark PropertyDetailsDelegate

- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details
{
    return -1;
}

- (NSInteger)detailsCount:(PropertyDetailsViewController *)details
{
    return -1;
}

- (PropertyDetails *)detailsPrevious:(PropertyDetailsViewController *)details
{
    return nil;
}

- (PropertyDetails *)detailsNext:(PropertyDetailsViewController *)details
{
    return nil;
}


#pragma mark -
#pragma mark Map Setup

- (void)centerMap
{
    PropertyCriteria *criteria = [[self history] criteria];
    
    CLLocationCoordinate2D center;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    if([criteria coordinates] != nil)
    {
        NSArray *coords = [[criteria coordinates] componentsSeparatedByString:@","];
        center.longitude = [[coords objectAtIndex:0] doubleValue];
        center.latitude = [[coords objectAtIndex:1] doubleValue];
        span.latitudeDelta = .05;
        span.longitudeDelta = .05;
    }
    else
    {
        NSArray *geoData = [self geocodeFromCriteria:criteria];
        center.longitude = [[geoData objectAtIndex:0] doubleValue];
        center.latitude = [[geoData objectAtIndex:1] doubleValue];
        span.longitudeDelta = [[geoData objectAtIndex:2] doubleValue];
        span.latitudeDelta = [[geoData objectAtIndex:3] doubleValue];
    }
    
    region.center = center;
    region.span = span;
    [[self mapView] setRegion:region];
    [[self mapView] setCenterCoordinate:center animated:YES];
}

// Returns {longitude, latitude, lonDelta, latDelta}
- (NSArray *)geocodeFromCriteria:(PropertyCriteria *)criteria
{
    // Format the criteria the query google for the geographic info
    NSString *street, *postalCode, *city, *state;
    if([criteria street] != nil)
        street = [NSString stringWithFormat:@"%@,", [[criteria street] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    else
        street = @"";
    if([criteria postalCode] != nil)
        postalCode = [NSString stringWithFormat:@"%@,", [[criteria postalCode] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    else
        postalCode = @"";
    if([criteria city] != nil)
        city = [NSString stringWithFormat:@"%@,", [[criteria city] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    else
        city = @"";
    if([criteria state] != nil)
        state = [NSString stringWithFormat:@"%@,", [[criteria state] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    else
        state = @"";
    
    // Get the data from Google
    NSString *parameterString = [NSString stringWithFormat:@"%@+%@+%@+%@", street, city, state, postalCode];
    return [self geocodeFromString:parameterString];
}

- (NSArray *)geocodeFromString:(NSString *)locationString
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:4];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=json&oe=utf8", locationString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    // The response consists of nested arrays and dictionaries (WTF?)
    // Extract the lat and long
    NSString *jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *geoData = [parser objectWithString:jsonString];
    [parser release];
    [jsonString release];
    NSArray *placemarks = [geoData valueForKey:@"Placemark"];
    NSDictionary *point = [placemarks objectAtIndex:0];
    NSArray *coords = [[point valueForKey:@"Point"] valueForKey:@"coordinates"];
    [ret addObject:[NSNumber numberWithDouble:[[coords objectAtIndex:0] doubleValue]]];
    [ret addObject:[NSNumber numberWithDouble:[[coords objectAtIndex:1] doubleValue]]];
    
    // Determine the lat/long delta to set the zoom
    NSDictionary *extendedData = [point valueForKey:@"ExtendedData"];
    NSDictionary *deltas = [extendedData valueForKey:@"LatLonBox"];
    double north = [[deltas valueForKey:@"north"] doubleValue];
    double east = [[deltas valueForKey:@"east"] doubleValue];
    double south = [[deltas valueForKey:@"south"] doubleValue];
    double west = [[deltas valueForKey:@"west"] doubleValue];
    [ret addObject:[NSNumber numberWithDouble:(east - west)]];
    [ret addObject:[NSNumber numberWithDouble:(north - south)]];
    
    if(error)
    {
        NSLog(@"Error geocoding: %@", error);
        // TODO: handle error
    }
    [error release];
    return ret;
}

// Used to geocode and display a single property after tapping the location cell
- (void)geocodePropertyFromAddress:(NSString *)address
{
    CLLocationCoordinate2D center;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    NSArray *geoData = [self geocodeFromString:[address stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    center.longitude = [[geoData objectAtIndex:0] doubleValue];
    center.latitude = [[geoData objectAtIndex:1] doubleValue];
    span.longitudeDelta = [[geoData objectAtIndex:2] doubleValue];
    span.latitudeDelta = [[geoData objectAtIndex:3] doubleValue];
      
    // Add a pin to the map at the address
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:center addressDictionary:nil];
    [[self mapView] addAnnotation:placemark];
    [placemark release];
    
    region.center = center;
    region.span = span;
    [[self mapView] setRegion:region];
    [[self mapView] setCenterCoordinate:center animated:YES];
}

- (void)geocodeProperties
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" 
                                              inManagedObjectContext:[[self history] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"history == %@", [self history]];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:kMaxMapItems];
    NSArray *summaries = [[self.history managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for(PropertySummary *summary in summaries)
    {
        double longitude, latitude;
        if(summary.location == nil)
        {
            NSString *location = [summary.details.location stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSArray *geoData = [self geocodeFromString:location];
            longitude = [[geoData objectAtIndex:0] doubleValue];
            latitude = [[geoData objectAtIndex:1] doubleValue];
            NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
            summary.location = coordinateString;
        }
        else
        {
            NSArray *coords = [summary.location componentsSeparatedByString:@","];
            longitude = [[coords objectAtIndex:0] doubleValue];
            latitude = [[coords objectAtIndex:1] doubleValue];
        }
        CLLocationCoordinate2D coordinates;
        coordinates.longitude = longitude;
        coordinates.latitude = latitude;
        
        PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithCoordinate:coordinates];
        annotation.title = summary.title;
        annotation.subtitle = summary.summary;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        [annotation release];
        [self.view addSubview:annotationView];
        [annotationView release];
    }
    
    [[[self history] managedObjectContext] save:&error];
    if(error)
    {
        NSLog(@"Error updating locations: %@", error);
        // TODO: handle saving error
    }
}


#pragma mark -
#pragma mark MKMapViewDelegate


@end
