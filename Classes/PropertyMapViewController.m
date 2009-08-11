#import "PropertyMapViewController.h"

#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"
#import "JSON.h"


// Maximum number of pins to load
#define kMaxMapItems 25


//Segmented Control items. Eventually put in a constants file so List view controller does not have to have a duplicate.
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


@implementation PropertyMapViewController

@synthesize history = history_;
@synthesize address = address_;
@synthesize mapView = mapView_;
@synthesize singleAddress = singleAddress_;
@synthesize summaries = summaries_;
@synthesize geocodedResponses = geocodedResponses_;
@synthesize maxPoint = maxPoint_;
@synthesize minPoint = minPoint_;

#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        NSMutableDictionary *geocodedResponses = [[NSMutableDictionary alloc] initWithCapacity:kMaxMapItems];
        [self setGeocodedResponses:geocodedResponses];
        [geocodedResponses release];
    }
    return self;
}

- (void)dealloc
{
    [history_ release];
    [mapView_ release];
    [summaries_ release];
    [geocodedResponses_ release];
 
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
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:[[self view] bounds]];
    [mapView setDelegate:self];
    [self setMapView:mapView];
    [mapView release];
    [[self view] addSubview:[self mapView]];
    
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
     
    if([criteria latitude] != nil && [[criteria latitude] doubleValue] != 0 
       && [criteria longitude] != nil && [[criteria longitude] doubleValue] != 0)
    {
        center.longitude = [[criteria longitude] doubleValue];
        center.latitude = [[criteria latitude] doubleValue];
        span.latitudeDelta = .05;
        span.longitudeDelta = .05;
        
        // Display the map using the cached data
        region.center = center;
        region.span = span;
        [[self mapView] setRegion:region];
        [[self mapView] setCenterCoordinate:center animated:YES];
    }
    else
    {
        // Geocode the address
        [self geocodeFromCriteria:criteria];
    }
}


#pragma mark -
#pragma mark Geocoding

- (void)geocodeFromCriteria:(PropertyCriteria *)criteria
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
    [self geocodeFromLocation:parameterString];
}

// Geocodes from any form of an address
- (void)geocodeFromLocation:(NSString *)locationString
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=json&oe=utf8", locationString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(urlConnection)
    {
        NSMutableData *data = [[NSMutableData alloc] init];
        [[self geocodedResponses] setObject:data forKey:[urlConnection description]];
        [data release];
    }
    else
    {
        NSLog(@"Error loading data for location: %@", locationString);
        // TODO: Handle error
    }
    [error release];
}

// Used to geocode and display a single property after tapping the location cell
- (void)geocodePropertyFromAddress:(NSString *)address
{
    [self setSingleAddress:YES];
    
    [self geocodeFromLocation:[address stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

- (void)geocodeProperties
{
    CLLocationCoordinate2D max;
    CLLocationCoordinate2D min;
    
    max.latitude = DBL_MIN;
    max.longitude = DBL_MIN;
    min.latitude = DBL_MAX;
    min.longitude = DBL_MAX;
    [self setMaxPoint:max];
    [self setMinPoint:min];
    
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
    
    NSArray *summaries = [[[self history] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [self setSummaries:summaries];
    [fetchRequest release];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    for(PropertySummary *summary in summaries)
    {
        if([summary location] == nil)
        {
            NSString *location = [[[summary details] location] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            [self geocodeFromLocation:location];
        }
        else
        {
            CLLocationCoordinate2D center;
            NSArray *coords = [[summary location] componentsSeparatedByString:@","];
            center.longitude = [[coords objectAtIndex:0] doubleValue];
            center.latitude = [[coords objectAtIndex:1] doubleValue];
            
            // Add a pin to the map at the address
            PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithCoordinate:center];
            [annotation setSummary:summary];
            
            [[self mapView] addAnnotation:annotation];
            [annotation release];
            
            // Update the min & max lat & lon based on the current coordinates
            [self updateMinMaxWithCoordinates:center];
        }
    }
    
    CLLocationCoordinate2D center;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    // Center the map based on the min & max lat & lon encountered
    double lonDelta = [self maxPoint].longitude - [self minPoint].longitude;
    double latDelta = [self maxPoint].latitude - [self minPoint].latitude;
    NSLog(@"\nmax lat: %f \nmin lat: %f \nmax lon: %f \nmin lon: %f", [self maxPoint].latitude, [self minPoint].latitude, [self maxPoint].longitude, [self minPoint].longitude);
    NSLog(@"lonDelta: %f\nlatDelta: %f", lonDelta, latDelta);
    
    // Add padding so the pins aren't on the very edge of the map
    span.longitudeDelta = lonDelta + 0.05;
    span.latitudeDelta = latDelta + 0.05;
    
    center.longitude = [self minPoint].longitude + (lonDelta / 2);
    center.latitude = [self minPoint].latitude + (latDelta / 2);
    
    region.center = center;
    region.span = span;
    
    [[self mapView] setRegion:region animated:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// Parses the response and adds a pin to the map
- (void)parseGeocodingResponseForConnection:(NSURLConnection *)connection WithAddress:(NSString *)address
{
    NSData *data = [[self geocodedResponses] objectForKey:[connection description]];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    
    CLLocationCoordinate2D center;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    // The response consists of nested arrays and dictionaries (WTF?)
    // Extract the lat and long
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *geoData = [parser objectWithString:jsonString];
    [parser release];
    [jsonString release];
    
    NSArray *placemarks = [geoData valueForKey:@"Placemark"];
    NSDictionary *point = [placemarks objectAtIndex:0];
    NSArray *coords = [[point valueForKey:@"Point"] valueForKey:@"coordinates"];
    
    center.longitude = [[coords objectAtIndex:0] doubleValue];
    center.latitude = [[coords objectAtIndex:1] doubleValue];
    
    // A coordinate of (0,0) means that the address couldn't be geocoded, so we shouldn't add a pin to the map. Fixes having a pin off the west coast of Africa
    if(center.longitude == 0 && center.latitude == 0)
    {
        return;
    }
    
    // Determine if the lat/lon are either the max or min seen
    [self updateMinMaxWithCoordinates:center];
    
    // Setup the pin to be placed on the map
    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithCoordinate:center];
    
    // Set the lat/long delta and center only if geocoding a single address
    if([self singleAddress])
    {
        // Determine the lat/long delta to set the zoom
        NSDictionary *extendedData = [point valueForKey:@"ExtendedData"];
        NSDictionary *deltas = [extendedData valueForKey:@"LatLonBox"];
        double north = [[deltas valueForKey:@"north"] doubleValue];
        double east = [[deltas valueForKey:@"east"] doubleValue];
        double south = [[deltas valueForKey:@"south"] doubleValue];
        double west = [[deltas valueForKey:@"west"] doubleValue];
        
        span.longitudeDelta = east - west;
        span.latitudeDelta = north - south;
        
        region.center = center;
        region.span = span;
        [[self mapView] setRegion:region];
        [[self mapView] setCenterCoordinate:center animated:YES];
        
        // The address iVar should be in a much nicer form, so use it instead of the method's parameter
        [annotation setAddress:[self address]];
        
        [self setSingleAddress:NO];
    }
    else
    {
        [annotation setAddress:address];
        
        // Save the lat/lon to the property (expensive but it only happens once for each address and there's no simple way around it)
        for(PropertySummary *summary in [self summaries])
        {
            NSString *resultAddress = [[[[summary details] location] componentsSeparatedByString:@","] objectAtIndex:0];
            if([resultAddress isEqual:address])
            {
                NSString *locationString = [NSString stringWithFormat:@"%f,%f", center.longitude, center.latitude];
                [summary setLocation:locationString];
                
                [annotation setSummary:summary];
                break;
            }
        }
        
        [[[self history] managedObjectContext] save:&error];
        if(error)
        {
            NSLog(@"Error saving location: %@", error);
            // TODO: handle saving error
        }
    }
    
    if(error)
    {
        NSLog(@"Error geocoding: %@", error);
        // TODO: handle error
    }
    [error release];
    
    // Add the pin to the map
    [[self mapView] addAnnotation:annotation];
    [annotation release];
}

- (void)updateMinMaxWithCoordinates:(CLLocationCoordinate2D)coordinates
{
    CLLocationCoordinate2D max;
    CLLocationCoordinate2D min;
    
    max.latitude =  (coordinates.latitude > [self maxPoint].latitude ? coordinates.latitude : [self maxPoint].latitude);
    max.longitude = (coordinates.longitude > [self maxPoint].longitude ? coordinates.latitude : [self maxPoint].longitude);
    
    min.latitude = (coordinates.latitude < [self minPoint].latitude ? coordinates.latitude : [self minPoint].latitude);
    min.longitude = (coordinates.longitude < [self minPoint].longitude ? coordinates.longitude : [self minPoint].longitude);
    
    [self setMaxPoint:max];
    [self setMinPoint:min];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Reset the length of the data for the given connection to 0
    [[[self geocodedResponses] objectForKey:[connection description]] setLength:0];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the received data to the data for the given connection
    [[[self geocodedResponses] objectForKey:[connection description]] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Get the address from the request and pass that into the parser to save the lat/lon
    NSArray *parameters = [[connection description] componentsSeparatedByString:@"="];
    NSString *address = [[[parameters objectAtIndex:1] componentsSeparatedByString:@","] objectAtIndex:0];
    address = [address stringByReplacingOccurrencesOfString:@"+" withString:@" "];

    [self parseGeocodingResponseForConnection:connection WithAddress:address];
 
    // release the connection, and the data object
    [[[self geocodedResponses] objectForKey:connection] release];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [[[self geocodedResponses] objectForKey:[connection description]] release];
    [connection release];
}

@end
