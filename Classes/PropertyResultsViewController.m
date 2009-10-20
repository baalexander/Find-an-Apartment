#import "PropertyResultsViewController.h"
#import "PropertyListAndMapConstants.h"
#import "PropertyCriteriaConstants.h"
#import "PropertyCriteria.h"
#import "PropertyImage.h"


// TODO: Implement low memory functions
// TODO: When exiting:
//      cancel geocoder
//      cancel parser
//      stop internet activity

@interface PropertyResultsViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, assign) NSInteger geocodeIndex;
- (void)geocodeNextProperty;
- (void)geocodeProperty:(PropertySummary *)property;
- (void)updateViewsWithGeocodedProperty:(PropertySummary *)property withIndex:(NSInteger)index;
@end


@implementation PropertyResultsViewController

@synthesize listViewController = listViewController_;
@synthesize mapViewController = mapViewController_;
@synthesize operationQueue = operationQueue_;
@synthesize isParsing = isParsing_;
@synthesize history = history_;
@synthesize summary = summary_;
@synthesize details = details_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize alertView = alertView_;
@synthesize geocoder = geocoder_;
@synthesize geocodeIndex = geocodeIndex_;


#pragma mark -
#pragma mark PropertyResultsViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        [self setGeocodeIndex:0];
    }
    
    return self;
}

- (void)dealloc
{
    [listViewController_ release];
    [mapViewController_ release];
    [operationQueue_ release];
    [history_ release];
    [summary_ release];
    [fetchedResultsController_ release];
    [alertView_ release];
    [geocoder_ release];
    
    [super dealloc];
}

- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    // Start geocoding properties if switching to a view requiring geocoded
    // properties and not already geocoding
    if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        [self geocodeNextProperty];
    }
    
    
//    // First create a CATransition object to describe the transition
//	CATransition *transition = [CATransition animation];
//	// Animate over 3/4 of a second
//	transition.duration = .5;
//	// using the ease in/out timing function
//	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//	
//	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
//	transition.type = kCATransitionFade;
//    //transition.subtype = kCATransitionFromLeft;
//	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
//	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
//	transition.delegate = self;
//	
//	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
//	[self.view.layer addAnimation:transition forKey:nil];
	
    // Switch between views based on selected segment
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        [[[self mapViewController] mapView] setHidden:YES];
        [[[self listViewController] tableView] setHidden:NO];
    }
    else if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        [[[self mapViewController] mapView] setHidden:NO];
        [[[self listViewController] tableView] setHidden:YES];
    }
}

- (void)parse:(NSURL *)url
{
    [self setIsParsing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Looking up property listings"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
    [self setAlertView:alertView];
    [alertView release];
    [[self alertView] show];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [self setOperationQueue:operationQueue];
    [operationQueue release];
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [parser setDelegate:self];
    [parser setUrl:url];
    [parser setItemDelimiter:kPropertyDelimiter];
    
    // Add the Parser to an operation queue for background processing (works on
    // a separate thread)
    [[self operationQueue] addOperation:parser];
    [parser release];
}

- (void)geocodeNextProperty
{
    // Looks for next property that has not been geocoded
    BOOL foundUngeocodedProperty = NO;
    for (;
         [self geocodeIndex] < [self propertyCount] && !foundUngeocodedProperty;
         [self setGeocodeIndex:([self geocodeIndex] + 1)])
    {
        PropertySummary *property = [self propertyAtIndex:[self geocodeIndex]];
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
        }
        // If property already geocoded, updates view controllers with the
        // geocoded property
        else if ([property longitude] != nil && [property latitude] != nil)
        {
            [self updateViewsWithGeocodedProperty:property withIndex:[self geocodeIndex]];
        }

    }
    
    // Every property has been geocoded, saves the context and update status
    if (!foundUngeocodedProperty)
    {
        // Saves the context
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving property context in Results geocoder's enqueue.");
        }
        
        //        // Updates the status
        //        [self setQuerying:NO];
    }
}

// Begins geocoding the next property
// Meant to be called as a selector with a delay to prevent flooding request to
// maps
- (void)geocodeProperty:(PropertySummary *)property
{    
    // Create a Geocoder with the property's location
    Geocoder *geocoder = [[Geocoder alloc] initWithLocation:[property location]];
    [self setGeocoder:geocoder];
    [geocoder release];
    
    [[self geocoder] setDelegate:self];
    [[self geocoder] start];
}

- (void)updateViewsWithGeocodedProperty:(PropertySummary *)property withIndex:(NSInteger)index
{
    // Updates the Map view with the new property
    [[self mapViewController] placeGeocodedPropertyOnMap:property
                                               withIndex:index];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        //History should NEVER be nil. Must always set before calling list view.
        if ([self history] == nil)
        {
            DebugLog(@"Error: History is nil in fetched results controller in List view controller.");
        }
        
        //Get managed object context from History
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        //Create the sort descriptors array based on the users sort by selection.
        PropertyCriteria *criteria = [[self history] criteria];
        NSSortDescriptor *descriptor;
        if ([[criteria sortBy] isEqual:kPropertyCriteriaSortByPriceAscending])
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        }
        else if ([[criteria sortBy] isEqual:kPropertyCriteriaSortByPriceDescending])
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:NO];
        }
        //Distance is the default search
        else
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
        }
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
        [descriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        //Search all summaries for the most recent search (summaries with this stored history)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(history = %@)", [self history]];
        [fetchRequest setPredicate:predicate];
        
        // Create and initialize the fetch results controller.
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                   managedObjectContext:managedObjectContext
                                                                                                     sectionNameKeyPath:nil 
                                                                                                              cacheName:@"Properties"];
        [fetchRequest release];
        [self setFetchedResultsController:fetchedResultsController];
        [fetchedResultsController release];
    }
    
    return fetchedResultsController_;
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
//    
    // Sorry equator and Prime Meridian, no 0 coordinates allowed because
    // _usually_ a parsing or downloading mishap
    if (coordinate.longitude != 0 && coordinate.latitude != 0)
    {
        // Subtracts 1 from geocode index because index would have been
        // incremented in the geocode next property loop
        NSInteger propertyIndex = [self geocodeIndex] - 1;
        
        PropertySummary *property = [self propertyAtIndex:propertyIndex];
        
        // Sets the coordinate data in the property
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:coordinate.longitude];
        [property setLongitude:longitude];
        [longitude release];
        
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:coordinate.latitude];
        [property setLatitude:latitude];
        [latitude release];
        
        // Update the views with the new geocoded property
        [self updateViewsWithGeocodedProperty:property withIndex:propertyIndex];
        
        // Saves the context
        // TODO: Only save every x number of times
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving property context in Property Geocoder's didFindCoordinate.");
        }
    }
    
    // Fetches next property to download
    [self geocodeNextProperty];
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


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Needed still?
    //If fetched objects is nil and not currently parsing results, the call perform fetch to get the most recent results. This would happen when switching from Map to List view. If the parse function already performed, then it has retrieved the results. This very much assumes that the parse function is being called before the view is loading.
    if (![self isParsing] && [[self fetchedResultsController] fetchedObjects] == nil)
    {
        if (![[self fetchedResultsController] performFetch:nil])
        {
            DebugLog(@"Error performing fetch in viewDidLoad.");
        }        
    }
    
    // Sets the views as subviews for transition animations and selects which is
    // visible by default
    [[self view] addSubview:[[self mapViewController] mapView]];
    [[[self mapViewController] mapView] setHidden:YES];
    // Centers the Map view controller
    [[self mapViewController] centerOnCriteria:[[self history] criteria]];
    
    [[self view] addSubview:[[self listViewController] tableView]];
    [[[self listViewController] tableView] setHidden:NO];
    
    // Segmented control
    NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
    [segmentOptions release];
    
    // Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
    [segmentedControl setSelectedSegmentIndex:kListItem];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    [[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Cancels any operations in the queue. This is for when pressing the back button and dismissing the view controller. This prevents the parser from still running and failing when calling its delegate.
    [[self operationQueue] cancelAllOperations];
}


#pragma mark -
#pragma mark PropertyDataSource

- (NSInteger)propertyCount
{
    NSInteger numberOfRows = 0;
    
    if ([[[self fetchedResultsController] sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = 
            [[[self fetchedResultsController] sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (PropertySummary *)propertyAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [[self fetchedResultsController] objectAtIndexPath:indexPath];

    return [[self fetchedResultsController] objectAtIndexPath:indexPath];
}

- (BOOL)deletePropertyAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    //Deletes the summary, should cascade to delete Details
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSManagedObjectContext *managedObjectContext = [summary managedObjectContext];
    [managedObjectContext deleteObject:summary];
    
    // Commit the change.
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        DebugLog(@"Error saving after deleting a property.");
        
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    [self setIsParsing:NO];
    
    if ([[[self history] summaries] count] == 0)
    {
        //Do not record these results
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        [managedObjectContext deleteObject:[self history]];
        
        [[self alertView] setTitle:nil];
        [[self alertView] setMessage:@"No properties found"];
        
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        DebugLog(@"Error saving context.");
    }
    
    if (![[self fetchedResultsController] performFetch:&error])
    {
        DebugLog(@"Error performing fetch.");
    }
    
    //Enable Map button
    UISegmentedControl *segmentedControl = (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
    [segmentedControl setEnabled:YES forSegmentAtIndex:kMapItem];
    
    [[[self listViewController] tableView] reloadData];
    
    //Send a cancel index of 1 to show the app sent the dismiss, not a user
    [[self alertView] dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    
    if (elementValue == nil || [elementValue length] == 0)
    {
        return;
    }
    
    //Shared attributes
    if ([elementName isEqual:@"link"])
    {
        [[self summary] setLink:elementValue];
        [[self details] setLink:elementValue];
    }
    else if ([elementName isEqual:@"location"])
    {
        [[self summary] setLocation:elementValue];
        [[self details] setLocation:elementValue];
    }
    else if ([elementName isEqual:@"price"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[elementValue integerValue]];
        [[self summary] setPrice:number];
        [[self details] setPrice:number];
        [number release];
    }
    //Summary attributes
    else if ([elementName isEqual:@"title"])
    {
        [[self summary] setTitle:elementValue];
    }
    else if ([elementName isEqual:@"subtitle"])
    {
        [[self summary] setSubtitle:elementValue];
    }
    else if ([elementName isEqual:@"summary"])
    {
        [[self summary] setSummary:elementValue];
    }
    //Details attributes
    else if ([elementName isEqual:@"agent"])
    {
        [[self details] setAgent:elementValue];
    }        
    else if ([elementName isEqual:@"bathrooms"])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[elementValue floatValue]];
        [[self details] setBathrooms:number];
        [number release];
    }
    else if ([elementName isEqual:@"bedrooms"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[elementValue integerValue]];
        [[self details] setBedrooms:number];
        [number release];
    }
    else if ([elementName isEqual:@"broker"])
    {
        [[self details] setBroker:elementValue];
    }
    else if ([elementName isEqual:@"copright"])
    {
        [[self details] setCopyright:elementValue];
    }
    else if ([elementName isEqual:@"copyright_link"])
    {
        [[self details] setCopyrightLink:elementValue];
    }
    else if ([elementName isEqual:@"description"])
    {
        [[self details] setDetails:elementValue];
    }
    else if ([elementName isEqual:@"email"])
    {
        [[self details] setEmail:elementValue];
    }
    else if ([elementName isEqual:@"image_link"])
    {
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        
        NSEntityDescription *imageEntity = [NSEntityDescription entityForName:@"PropertyImage" inManagedObjectContext:managedObjectContext];
        PropertyImage *image = [[PropertyImage alloc] initWithEntity:imageEntity insertIntoManagedObjectContext:managedObjectContext];
        [image setUrl:elementValue];
        
        [[self details] addImagesObject:image];
        [image release];
    }
    else if ([elementName isEqual:@"link"])
    {
        [[self details] setLink:elementValue];
    }
    else if ([elementName isEqual:@"school"])
    {
        [[self details] setSchool:elementValue];
    }
    else if ([elementName isEqual:@"source"])
    {
        [[self details] setSource:elementValue];
    }
    else if ([elementName isEqual:@"square_feet"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[elementValue integerValue]];
        [[self details] setSquareFeet:number];
        [number release];
    }
    else if ([elementName isEqual:@"year"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[elementValue integerValue]];
        [[self details] setYear:number];
        [number release];
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    
    NSEntityDescription *detailsEntity = [NSEntityDescription entityForName:@"PropertyDetails" inManagedObjectContext:managedObjectContext];
    PropertyDetails *details = [[PropertyDetails alloc] initWithEntity:detailsEntity insertIntoManagedObjectContext:managedObjectContext];
    [self setDetails:details];
    [details release];
    
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
    PropertySummary *summary = [[PropertySummary alloc] initWithEntity:summaryEntity insertIntoManagedObjectContext:managedObjectContext];
    [self setSummary:summary];
    [summary release];
    
    //Sets relationships
    [[self summary] setHistory:[self history]];
    [[self summary] setDetails:[self details]];
    [[self details] setSummary:[self summary]];
}

- (void)parserDidEndItem:(XmlParser *)parser
{
    //Currently nothing to do
}

- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error
{
    [self setIsParsing:NO];
    
    //Do not record these results
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    [managedObjectContext deleteObject:[self history]];    
    
    [[self alertView] setTitle:@"Error finding results"];
    [[self alertView] setMessage:[error localizedDescription]];
}

@end
