#import "PropertyMapViewController.h"

#import "PropertyGeocodeParser.h"
#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"


// Maximum number of pins to load
#define kMaxMapItems 25

//Segmented Control items. Eventually put in a constants file so List view controller does not have to have a duplicate.
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


@interface PropertyMapViewController ()
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) Placemark *placemark;
@property (nonatomic, assign) NSUInteger summaryCount;
@property (nonatomic, assign) CLLocationCoordinate2D maxPoint;
@property (nonatomic, assign) CLLocationCoordinate2D minPoint;
@property (nonatomic, assign) BOOL firstTime;
- (void)enqueueSummary:(PropertySummary *)summary;
- (void)updateMinMaxWithCoordinates:(CLLocationCoordinate2D)coordinates;
@end


@implementation PropertyMapViewController

@synthesize history = history_;
@synthesize mapView = mapView_;
@synthesize operationQueue = operationQueue_;
@synthesize placemark = placemark_;
@synthesize summaryCount = summaryCount_;
@synthesize maxPoint = maxPoint_;
@synthesize minPoint = minPoint_;
@synthesize firstTime = firstTime_;


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
    [operationQueue_ release];
    [placemark_ release];
 
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

- (void)geocodePropertiesFromHistory:(PropertyHistory *)history
{
    [self setHistory:history];
    
    [self setFirstTime:YES];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [self setOperationQueue:operationQueue];
    [operationQueue release];
    
    NSSet *summaries = [[self history] summaries];
    [self setSummaryCount:[summaries count]];
    
    NSUInteger i = 0;
    for (PropertySummary *summary in summaries)
    {
        i++;
        if (i >= kMaxMapItems)
        {
            break;
        }        
        
        [self enqueueSummary:summary];
    }
}

- (void)geocodePropertyFromSummary:(PropertySummary *)summary
{
    [self setFirstTime:YES];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [self setOperationQueue:operationQueue];
    [operationQueue release];
    
    [self setSummaryCount:1];
    
    [self enqueueSummary:summary];
}

- (void)enqueueSummary:(PropertySummary *)summary
{
    //Add the Parser to an operation queue for background processing (works on a separate thread)
    PropertyGeocodeParser *parser = [[PropertyGeocodeParser alloc] initWithSummary:summary];
    [parser setDelegate:self];
    [[self operationQueue] addOperation:parser];
    [parser release];
}

- (void)updateMinMaxWithCoordinates:(CLLocationCoordinate2D)coordinates
{
    CLLocationCoordinate2D max;
    CLLocationCoordinate2D min;
    
    max.latitude =  (coordinates.latitude > [self maxPoint].latitude ? coordinates.latitude : [self maxPoint].latitude);
    max.longitude = (coordinates.longitude > [self maxPoint].longitude ? coordinates.longitude : [self maxPoint].longitude);
    
    min.latitude = (coordinates.latitude < [self minPoint].latitude ? coordinates.latitude : [self minPoint].latitude);
    min.longitude = (coordinates.longitude < [self minPoint].longitude ? coordinates.longitude : [self minPoint].longitude);
    
    [self setMaxPoint:max];
    [self setMinPoint:min];
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
    
    if ([self history])
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
    }
    else
    {   
//        [[self navigationItem] setTitle:[self address]];
//        [self setSingleAddress:YES];
//        [self geocodeFromLocation:[self address]];
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
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    //Placemark's coordinate
    CLLocationCoordinate2D coordinate = [[self placemark] coordinates];
    
    //Sets coordinates in Summary
    PropertySummary *summary = [(PropertyGeocodeParser *)parser summary];
    NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
    [summary setLongitude:longitude];
    [longitude release];
    NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
    [summary setLatitude:latitude];
    [latitude release];
    
    // Setup the pin to be placed on the map
    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithCoordinate:coordinate];
    [annotation setSummary:summary];
    [annotation setAddress:[[self placemark] address]];
    
    // Add the pin to the map
    [[self mapView] addAnnotation:annotation];
    [annotation release];
    
    //Sets map region to latitude/longitude box results from Google if box given and a single result
    if ([self summaryCount] == 1 
            && [[self placemark] north] != 0
            && [[self placemark] east] != 0
            && [[self placemark] south] != 0
            && [[self placemark] west] != 0)
    {                
        MKCoordinateSpan span;
        span.longitudeDelta = [[self placemark] east] - [[self placemark] west];
        span.latitudeDelta = [[self placemark] north] - [[self placemark] south];
        
        MKCoordinateRegion region;
        region.center = coordinate;
        region.span = span;
        [[self mapView] setRegion:region animated:YES]; 
    }
    else
    {
        //Sets max and min coordinates to this property's coordinates
        if ([self firstTime])
        {
            [self setFirstTime:NO];
            
            CLLocationCoordinate2D max;
            max.latitude = coordinate.latitude;
            max.longitude = coordinate.longitude;
            [self setMaxPoint:max];
            
            CLLocationCoordinate2D min;
            min.latitude = coordinate.latitude;
            min.longitude = coordinate.longitude;
            [self setMinPoint:min];
        }
        //Determine if the lat/lon are either the max or min
        else
        {
            [self updateMinMaxWithCoordinates:coordinate];                
        }
        
        //Center the map based on the min & max lat & lon encountered
        double longitudeDelta = [self maxPoint].longitude - [self minPoint].longitude;
        double latitudeDelta = [self maxPoint].latitude - [self minPoint].latitude;
        
        CLLocationCoordinate2D center;
        center.longitude = [self minPoint].longitude + (longitudeDelta / 2);
        center.latitude = [self minPoint].latitude + (latitudeDelta / 2);  
        
        // Add padding so the pins aren't on the very edge of the map
        MKCoordinateSpan span;
        span.longitudeDelta = longitudeDelta + 0.04;
        span.latitudeDelta = latitudeDelta + 0.04;
        
        MKCoordinateRegion region;
        region.center = center;
        region.span = span;
        [[self mapView] setRegion:region animated:YES]; 
    }
    
    //If no more queued operations, saves context to save the new summary coordinate data.
    if ([[[self operationQueue] operations] count] == 0)
    {
        //TODO: Save context
    }
}

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    NSDictionary *attributes = [xmlElement attributes];
    
    //Address format is: <address>2600 Lake Austin Blvd, Austin, TX 78703, USA</address>
    if ([elementName isEqual:@"address"])
    {
        if (elementValue != nil)
        {
            //Gets everything preceeding the first comma. Hopefully the street or maybe the city.
            NSArray *addressComponents = [elementValue componentsSeparatedByString:@","];
            if ([addressComponents count] > 0)
            {
                [[self placemark] setAddress:[addressComponents objectAtIndex:0]];
            }
        }
    }
    //Coordinate format is: <coordinates>-97.7743400,30.2797450,0</coordinates>
    //First param is longitude, second param is latitude, can ignroe third param
    if ([elementName isEqual:@"coordinates"])
    {
        if (elementValue != nil)
        {
            NSArray *coordinateComponents = [elementValue componentsSeparatedByString:@","];
            if ([coordinateComponents count] >= 2)
            {
                CLLocationCoordinate2D coordinates;
                coordinates.longitude = [[coordinateComponents objectAtIndex:0] doubleValue];
                coordinates.latitude = [[coordinateComponents objectAtIndex:1] doubleValue];
                
                [[self placemark] setCoordinates:coordinates];
            }
        }
    }
    //LatLonBox format is: <LatLonBox north="30.2847876" south="30.2784924" east="-97.7719254" west="-97.7782206"/>
    else if ([elementName isEqual:@"LatLonBox"])
    {
        if (attributes != nil)
        {
            [[self placemark] setNorth:[[attributes objectForKey:@"north"] doubleValue]];
            [[self placemark] setEast:[[attributes objectForKey:@"east"] doubleValue]];
            [[self placemark] setSouth:[[attributes objectForKey:@"south"] doubleValue]];
            [[self placemark] setWest:[[attributes objectForKey:@"west"] doubleValue]];
        }
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    Placemark *placemark = [[Placemark alloc] init];
    [self setPlacemark:placemark];
    [placemark release];    
}

- (void)parserDidEndItem:(XmlParser *)parser
{
    //Currently nothing to do
}

- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error
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
