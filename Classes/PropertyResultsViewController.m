#import "PropertyResultsViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "PropertyResultsConstants.h"
#import "PropertyCriteriaConstants.h"
#import "PropertyCriteria.h"
#import "PropertyImage.h"
#import "PropertyDetailsViewController.h"
#import "ARGeoViewController.h"
#import "ARGeoCoordinate.h"


@interface PropertyResultsViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, assign, getter=isParsing) BOOL parsing;
@property (nonatomic, assign, getter=isGeocoding) BOOL geocoding;
@property (nonatomic, retain) PropertySummary *property;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger previousSelectedSegment;
@property (nonatomic, retain) Geocoder *geocoder;
@property (nonatomic, assign) NSInteger geocodeIndex;
- (void)geocodeProperty:(PropertySummary *)property;
- (void)updateViewsWithGeocodedProperty:(PropertySummary *)property withIndex:(NSInteger)index;
- (void)updateNetworkActivityIndicator;
@end


@implementation PropertyResultsViewController

@synthesize listViewController = listViewController_;
@synthesize mapViewController = mapViewController_;
@synthesize arViewController = arViewController_;
@synthesize operationQueue = operationQueue_;
@synthesize parsing = parsing_;
@synthesize geocoding = geocoding_;
@synthesize history = history_;
@synthesize property = property_;
@synthesize details = details_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize alertView = alertView_;
@synthesize segmentedControl = segmentedControl_;
@synthesize previousSelectedSegment = previousSelectedSegment_;
@synthesize geocoder = geocoder_;
@synthesize geocodeIndex = geocodeIndex_;
@synthesize mapIsDirty = mapIsDirty_;


#pragma mark -
#pragma mark PropertyResultsViewController

- (void)dealloc
{
    [listViewController_ release];
    [mapViewController_ release];
    [arViewController_ release];
    [operationQueue_ release];
    [history_ release];
    [property_ release];
    [details_ release];
    [fetchedResultsController_ release];
    [alertView_ release];
    [segmentedControl_ release];
    [geocoder_ release];
    
    [super dealloc];
}

- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;

    // These views require geocoded properties
    if ([segmentedControl selectedSegmentIndex] == kMapItem
        || [segmentedControl selectedSegmentIndex] == kArItem)
    {
        // Lazily creates AR view controller
        if ([self arViewController] == nil)
        {
            PropertyArViewController *arViewController = [[PropertyArViewController alloc] init];
            [self setArViewController:arViewController];
            [arViewController release];
            [[self arViewController] setPropertyArViewDelegate:self];
            [[self arViewController] setPropertyDelegate:self];
            [[self arViewController] setPropertyDataSource:self];
        }        
        
        if (![self isGeocoding] && [self mapIsDirty])
        {
            [self setMapIsDirty:NO];
            [self geocodeNextProperty];            
        }
    }
    
    // Create a tranisiton animation to switch views
    CATransition *transition = [CATransition animation];
    [transition setDuration:.5];
    // Using the ease in/out timing function
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // Type of transition
    [transition setType:kCATransitionFade];
    
    // Add the transition to the containerView's layer. This will perform the
    // transition based on how the contents change.
    [[[self view] layer] addAnimation:transition forKey:nil];
    
    // Switch between views based on selected segment
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        [[[self mapViewController] mapView] setHidden:YES];
        [[[self listViewController] tableView] setHidden:NO];
        [self setPreviousSelectedSegment:kListItem];
    }
    else if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        [[[self mapViewController] mapView] setHidden:NO];
        [[[self listViewController] tableView] setHidden:YES];
        [self setPreviousSelectedSegment:kMapItem];
    }
    else if ([segmentedControl selectedSegmentIndex] == kArItem)
    {
        [[self arViewController] show];
    }
}

- (void)parse:(NSURL *)url
{
    [self setParsing:YES];
    
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
    [parser setItemDelimiter:"property"];
    
    // Add the Parser to an operation queue for background processing (works on
    // a separate thread)
    [[self operationQueue] addOperation:parser];
    [parser release];
}

- (void)geocodeNextProperty
{
    // If already geocoding, do not go onto the next property
    if ([self isGeocoding])
    {
        return;
    }
    
    [self setGeocoding:YES];
    
    // Looks for next property that has not been geocoded
    BOOL foundUngeocodedProperty = NO;
    for (;
         [self geocodeIndex] < [self numberOfPropertiesInView:[self view]]
            && [self geocodeIndex] < kMaxGeocodeProperties
            && !foundUngeocodedProperty;
         [self setGeocodeIndex:([self geocodeIndex] + 1)])
    {
        PropertySummary *property = [self view:[self view] propertyAtIndex:[self geocodeIndex]];
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
        [self setGeocoding:NO];
        
        // Saves the context if there's changes
        NSError *error;
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving property context in Results geocoder's enqueue.");
        }
    }
}

- (void)resetGeocoding
{
    [self setGeocoding:NO];
    [self setGeocodeIndex:0];
}

// Begins geocoding the next property
// Meant to be called as a selector with a delay to prevent flooding request to
// maps
- (void)geocodeProperty:(PropertySummary *)property
{
    // If cancel was called before this, stop all geocoding
    if (![self isGeocoding])
    {
        return;
    }

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
    [[self mapViewController] addGeocodedProperty:property atIndex:index];
    [[self arViewController] addGeocodedProperty:property atIndex:index];    
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        // History should NEVER be nil. Must always set before calling list view.
        if ([self history] == nil)
        {
            DebugLog(@"History cannot be nil");
        }
        
        // Get managed object context from History
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Create the sort descriptors array based on the users sort by selection.
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
        // Distance is the default search
        else
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
        }
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
        [descriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        // Search all summaries for the most recent search (summaries with this stored history)
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

- (void)setGeocoding:(BOOL)geocoding
{
    geocoding_ = geocoding;
    
    [self updateNetworkActivityIndicator];
}

- (void)setParsing:(BOOL)parsing
{
    parsing_ = parsing;
    
    [self updateNetworkActivityIndicator];
}

- (void)updateNetworkActivityIndicator
{
    // Activate the network indicator if geocoding or parsing
    BOOL activity = [self isGeocoding] || [self isParsing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:activity];
}


#pragma mark -
#pragma mark PropertyArViewDelegate

- (void)arViewWillHide:(PropertyArViewController *)arView;
{
    [[self segmentedControl] setSelectedSegmentIndex:[self previousSelectedSegment]];
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
        // Subtracts 1 from geocode index because index would have been
        // incremented in the geocode next property loop
        NSInteger propertyIndex = [self geocodeIndex] - 1;
        
        PropertySummary *property = [self view:[self view] propertyAtIndex:propertyIndex];
        
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
    // If cancel was called before this call back, stop all geocoding
    if (![self isGeocoding])
    {
        return;
    }

    [self setGeocoding:NO];

    // User doesn't need to know of geocoding error... probably
    DebugLog(@"Geocoder did fail with error:%@", [error localizedDescription]);
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make Map dirty initially so will be geocoded when switching to it
    [self setMapIsDirty:YES];
    
    // If not in the middle of parsing, fetch all objects
    // This will occur when going from History view controller to Results
    if (![self isParsing])
    {
        if (![[self fetchedResultsController] performFetch:nil])
        {
            DebugLog(@"Error performing fetch.");
        }        
    }
    
    // Sets the views as subviews for transition animations and selects which is
    // visible by default
    [[self view] addSubview:[[self mapViewController] mapView]];
    [[[self mapViewController] mapView] setHidden:YES];

    [[self view] addSubview:[[self listViewController] tableView]];
    [[[self listViewController] tableView] setHidden:NO];
    
    // Centers the Map view controller
    [[self mapViewController] centerOnCriteria:[[self history] criteria]];
    
    // Segmented control
    NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", @"augmented", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
    [segmentOptions release];
    [self setSegmentedControl:segmentedControl];
    [segmentedControl release];
    
    // Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
    [[self segmentedControl] setSelectedSegmentIndex:kListItem];
    [self setPreviousSelectedSegment:kListItem];
    [[self segmentedControl] addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    [[self segmentedControl] setSegmentedControlStyle:UISegmentedControlStyleBar];
    [[self segmentedControl] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:[self segmentedControl]];
    [[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Need to tell List view to deselect its row
    // Is ignored if the List view has no selected row
    [[self listViewController] deselectRow];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Cancels any operations in the queue. This is for when pressing the back
    // button and dismissing the view controller. This prevents any asynchronous
    // actions like parser or geocoder from still running and failing when
    // calling its delegate. Does not apply when presenting a modal view, like
    // when showing the AR view, since we still want to geocode then and this 
    // class isn't really going away at that point.
    if ([self modalViewController] == nil)
    {
        [[self operationQueue] cancelAllOperations];
        [[self geocoder] cancel];
        [self setParsing:NO];
        [self setGeocoding:NO];
    }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // If a user clicked the button, then the index is 0.
    // If the parser finished successfully, it will dismiss with a 1
    if (buttonIndex == 0)
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark PropertyDataSource

- (NSInteger)numberOfPropertiesInView:(UIView *)view
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

- (PropertySummary *)view:(UIView *)view propertyAtIndex:(NSInteger)index;
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [[self fetchedResultsController] objectAtIndexPath:indexPath];

    return [[self fetchedResultsController] objectAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark PropertyDetailsViewControllerDelegate

- (void)onDetailsClose
{
    // If we backed out of the details view, re-click the AR segment button again.
    if ([[self segmentedControl] selectedSegmentIndex] == kArItem)
    {
        [[self segmentedControl] setSelectedSegmentIndex:kListItem];
        [[self segmentedControl] setSelectedSegmentIndex:kArItem];
    }
}


#pragma mark -
#pragma mark PropertyResultsDelegate

- (void)view:(UIView *)view didSelectPropertyAtIndex:(NSInteger)index
{
    // Gets details from relationship with summary
    PropertySummary *property = [self view:[self view] propertyAtIndex:index];
    PropertyDetails *details = [property details];   
    
    // Pushes the Details view controller
    PropertyDetailsViewController *detailsViewController = [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView" bundle:nil];
    [detailsViewController setDelegate:self];
    [detailsViewController setPropertyDataSource:self];
    [detailsViewController setPropertyIndex:index];
    [detailsViewController setDetails:details];
    
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    
    [detailsViewController release];
}


#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    // If cancel was called before this call back, stop all parsing
    if (![self isParsing])
    {
        return;
    }
    
    [self setParsing:NO];
    
    if ([[[self history] summaries] count] == 0)
    {
        // Do not record these results
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
    
    // Reloads the List view
    [[[self listViewController] tableView] reloadData];
    
    // Tell Map view data is out of sync and needs to be loaded
    [self setMapIsDirty:YES];
    
    // Dismisses the progress alert
    // Send a cancel index of 1 to show the app sent the dismiss, not a user
    [[self alertView] dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    // If cancel was called before this call back, stop all parsing
    if (![self isParsing])
    {
        return;
    }
    
    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    
    if (elementValue == nil || [elementValue length] == 0)
    {
        return;
    }
    
    // Shared attributes
    if ([elementName isEqual:@"link"])
    {
        [[self property] setLink:elementValue];
        [[self details] setLink:elementValue];
    }
    else if ([elementName isEqual:@"location"])
    {
        [[self property] setLocation:elementValue];
        [[self details] setLocation:elementValue];
    }
    else if ([elementName isEqual:@"price"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[elementValue integerValue]];
        [[self property] setPrice:number];
        [[self details] setPrice:number];
        [number release];
    }

    // Summary attributes
    else if ([elementName isEqual:@"title"])
    {
        [[self property] setTitle:elementValue];
    }
    else if ([elementName isEqual:@"subtitle"])
    {
        [[self property] setSubtitle:elementValue];
    }
    else if ([elementName isEqual:@"summary"])
    {
        [[self property] setSummary:elementValue];
    }
    else if ([elementName isEqual:@"latitude"])
    {
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:[elementValue doubleValue]];
        [[self property] setLatitude:latitude];
        [latitude release];
    }
    else if ([elementName isEqual:@"longitude"])
    {
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:[elementValue doubleValue]];
        [[self property] setLongitude:longitude];
        [longitude release];
    }

    // Details attributes
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
    // If cancel was called before this call back, stop all parsing
    if (![self isParsing])
    {
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    
    NSEntityDescription *detailsEntity = [NSEntityDescription entityForName:@"PropertyDetails" inManagedObjectContext:managedObjectContext];
    PropertyDetails *details = [[PropertyDetails alloc] initWithEntity:detailsEntity insertIntoManagedObjectContext:managedObjectContext];
    [self setDetails:details];
    [details release];
    
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
    PropertySummary *property = [[PropertySummary alloc] initWithEntity:summaryEntity insertIntoManagedObjectContext:managedObjectContext];
    [self setProperty:property];
    [property release];
    
    // Sets relationships
    [[self property] setHistory:[self history]];
    [[self property] setDetails:[self details]];
    [[self details] setSummary:[self property]];
}

- (void)parserDidEndItem:(XmlParser *)parser
{
    // Currently nothing to do
}

- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error
{
    // If cancel was called before this call back, stop all parsing
    if (![self isParsing])
    {
        return;
    }
    
    [self setParsing:NO];
    
    // Do not record these results
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    [managedObjectContext deleteObject:[self history]];    
    
    [[self alertView] setTitle:@"Error finding results"];
    [[self alertView] setMessage:[error localizedDescription]];
}

@end
