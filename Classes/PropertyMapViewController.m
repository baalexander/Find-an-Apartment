#import "PropertyMapViewController.h"

#import "PropertyFavoritesViewController.h"
#import "PropertyListViewController.h"
#import "PropertyCriteria.h"
#import "PropertyAnnotation.h"
#import "PropertyListAndMapConstants.h"
#import "UrlUtil.h"


@interface PropertyMapViewController ()
@property (nonatomic, retain) NSArray *summaries;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) Placemark *placemark;
@property (nonatomic, assign) CLLocationCoordinate2D maxPoint;
@property (nonatomic, assign) CLLocationCoordinate2D minPoint;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) NSInteger summaryIndex;
@property (nonatomic, assign) NSInteger selectedIndex;
- (void)geocodeProperties;
- (BOOL)enqueueNextSummary;
- (void)mapPlacemark:(Placemark *)placemark ;
@end


@implementation PropertyMapViewController

@synthesize history = history_;
@synthesize summaries = summaries_;
@synthesize summary = summary_;
@synthesize mapView = mapView_;
@synthesize operationQueue = operationQueue_;
@synthesize placemark = placemark_;
@synthesize maxPoint = maxPoint_;
@synthesize minPoint = minPoint_;
@synthesize isCancelled = isCancelled_;
@synthesize isFromFavorites = isFromFavorites_;
@synthesize summaryIndex = summaryIndex_;
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
    [history_ release];
    [summaries_ release];
    [summary_ release];
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
        if ([self isFromFavorites])
        {
            PropertyFavoritesViewController *favoritesViewController = [[PropertyFavoritesViewController alloc] initWithNibName:@"PropertyFavoritesView" bundle:nil];
            [favoritesViewController setHistory:[self history]];
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
            [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:favoritesViewController];
            [favoritesViewController release];
            [[self navigationController] setViewControllers:viewControllers animated:NO];
            [viewControllers release];            
        }
        else
        {
            PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
            [listViewController setHistory:[self history]];
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
            [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:listViewController];
            [listViewController release];
            [[self navigationController] setViewControllers:viewControllers animated:NO];
            [viewControllers release];
        }
    }
}

- (IBAction)pinClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self setSelectedIndex:[button tag]];
    PropertySummary *summary = [[self summaries] objectAtIndex:[self selectedIndex]];
    
    //Pushes the Details view controller with the summary
    PropertyDetailsViewController *detailsViewController = [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView" bundle:nil];
    [detailsViewController setDelegate:self];
    [detailsViewController setDetails:[summary details]];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
}

- (void)geocodeProperties
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [self setOperationQueue:operationQueue];
    [operationQueue release];
    
    [self setSummaryIndex:0];
    [self enqueueNextSummary];
}

//Returns NO if no properties left to enqueue
- (BOOL)enqueueNextSummary
{
    //Loops through list of summaries.
    //If a cached result (has longitude and latitude), then maps. If an uncached result, enqueues to parse and returns YES.
    for (; [self summaryIndex] < (NSInteger)[[self summaries] count] && [self summaryIndex] < kMaxMapItems; [self setSummaryIndex:[self summaryIndex] + 1])
    {
        PropertySummary *summary = [[self summaries] objectAtIndex:[self summaryIndex]];
        //If longitude and latitude already cache and not a single property, add directly to map
        //Does the check for single property, because need to fetch additional data, like region box
        if ([[self summaries] count] > 1 && [summary longitude] != nil && [summary latitude] != nil)
        {
            //Creates Placemark
            Placemark *placemark = [[Placemark alloc] init];
            [placemark setAddress:[summary location]];            
            CLLocationCoordinate2D coordinate;
            coordinate.longitude = [[summary longitude] doubleValue];
            coordinate.latitude = [[summary latitude] doubleValue];
            [placemark setCoordinate:coordinate];
            
            //Adds to map
            [self mapPlacemark:placemark];
        }
        else
        {
            //Add the Parser to an operation queue for background processing (works on a separate thread)
            XmlParser *parser = [[XmlParser alloc] init];
            [parser setDelegate:self];
            
            //Sets item delimiter
            [parser setItemDelimiter:kGeocodeDelimiter];
            
            //Sets URL
            NSString *encodedLocation = [UrlUtil encodeUrl:[summary location]];
            NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=xml&oe=utf8", encodedLocation];
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            [urlString release];
            [parser setUrl:url];
            [url release];    
            
            [[self operationQueue] addOperation:parser];
            [parser release];
            
            return YES;
        }
    }
    
    return NO;
}
            
- (void)mapPlacemark:(Placemark *)placemark
{
    // Setup the pin to be placed on the map
    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithPlacemark:placemark];
    [annotation setSummaryIndex:[self summaryIndex]];
    [[self mapView] addAnnotation:annotation];
    [annotation release];
    
    if ([self summaryIndex] == 0)
    {
        //Sets map region to latitude/longitude box results from Google if box given and a single result
        if ([[self summaries] count] == 1 
            && [placemark north] != 0
            && [placemark east] != 0
            && [placemark south] != 0
            && [placemark west] != 0)
        {                
            MKCoordinateSpan span;
            span.longitudeDelta = [[self placemark] east] - [[self placemark] west];
            span.latitudeDelta = [[self placemark] north] - [[self placemark] south];
            
            MKCoordinateRegion region;
            region.center = [placemark coordinate];
            region.span = span;
            [[self mapView] setRegion:region animated:YES]; 
        }
        //Centers map on pin, with padding
        else
        {
            // Add padding so the pins aren't on the very edge of the map
            MKCoordinateSpan span;
            span.longitudeDelta = kLongitudeDelta;
            span.latitudeDelta = kLatitudeDelta;
            
            MKCoordinateRegion region;
            region.center = [placemark coordinate];
            region.span = span;
            [[self mapView] setRegion:region animated:YES]; 
        }
    }    
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
                
            //Adds button the annnotation
            UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [detailsButton setTag:[propertyAnnotation summaryIndex]];
            [detailsButton addTarget:self action:@selector(pinClick:) forControlEvents:UIControlEventTouchUpInside];
            detailsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            detailsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [annotationView setRightCalloutAccessoryView:detailsButton];
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
        NSArray *summaries = [[[self history] summaries] allObjects];
        [self setSummaries:summaries];
        [self geocodeProperties];              
        
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
    else if ([self summary])
    {
        [self setTitle:[[self summary] location]];
        
        NSArray *summaries = [[NSArray alloc] initWithObjects:[self summary], nil];
        [self setSummaries:summaries];
        [summaries release];
        [self geocodeProperties];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{

    [self setIsCancelled:YES];
    //Cancels any operations in the queue. This is for when pressing the back button and dismissing the view controller. This prevents the parser from still running and failing when calling its delegate.
    [[self operationQueue] cancelAllOperations];
}


//PropertyDetailsDelegate is used by Property Details view controller's segment control for previous/next
#pragma mark -
#pragma mark PropertyDetailsDelegate

- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details
{
    return [self selectedIndex];
}

- (NSInteger)detailsCount:(PropertyDetailsViewController *)details
{
    return [[self summaries] count];
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
    PropertySummary *summary = [[self summaries] objectAtIndex:[self selectedIndex]];

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
    PropertySummary *summary = [[self summaries] objectAtIndex:[self selectedIndex]];
    
    return [summary details];    
}


#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    if ([self isCancelled])
    {
        return;
    }

    //Placemark's coordinate
    CLLocationCoordinate2D coordinate = [[self placemark] coordinate];

    //Sorry equator and Prime Meridian, no 0 coordinates allowed because _usually_ a parsing or downloading mishap
    if (coordinate.longitude != 0 && coordinate.latitude != 0)
    {
        //Sets Coordinates and updates Location in Summary
        PropertySummary *summary = [[self summaries] objectAtIndex:[self summaryIndex]];
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
        [summary setLongitude:longitude];
        [longitude release];
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [summary setLatitude:latitude];
        [latitude release];
        [summary setLocation:[[self placemark] address]];
        
        //Maps the current summary
        [self mapPlacemark:[self placemark]];

        //Enqueues next summary
        [self setSummaryIndex:[self summaryIndex] + 1];
        if (![self enqueueNextSummary])
        {
            //If no more queued operations, saves context to save the new summary coordinate data.            
            if ([self history] != nil)
            {
                NSError *error;
                NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
                if (![managedObjectContext save:&error])
                {
                    DebugLog(@"Error saving history context in Maps.");
                }
            }
            else if ([self summary] != nil)
            {
                NSError *error;
                NSManagedObjectContext *managedObjectContext = [[self summary] managedObjectContext];
                if (![managedObjectContext save:&error])
                {
                    DebugLog(@"Error saving summary context in Maps.");
                }            
            }            
        }
    }    
}

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    if ([self isCancelled])
    {
        return;
    }

    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    NSDictionary *attributes = [xmlElement attributes];
    
    //Address format is: <address>2600 Lake Austin Blvd, Austin, TX 78703, USA</address>
    if ([elementName isEqual:@"address"])
    {
        if (elementValue != nil)
        {
            [[self placemark] setAddress:elementValue];
        }
    }
    //Coordinate format is: <coordinates>-97.7743400,30.2797450,0</coordinates>
    //First param is longitude, second param is latitude, can ignore third param
    if ([elementName isEqual:@"coordinates"])
    {
        if (elementValue != nil)
        {
            NSArray *coordinateComponents = [elementValue componentsSeparatedByString:@","];
            if ([coordinateComponents count] >= 2)
            {
                CLLocationCoordinate2D coordinate;
                coordinate.longitude = [[coordinateComponents objectAtIndex:0] doubleValue];
                coordinate.latitude = [[coordinateComponents objectAtIndex:1] doubleValue];
                
                [[self placemark] setCoordinate:coordinate];
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
    if ([self isCancelled])
    {
        return;
    }
    
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
