#import "PropertyResultsViewController.h"
#import "PropertyListAndMapConstants.h"
#import "PropertyCriteriaConstants.h"
#import "PropertyCriteria.h"
#import "PropertyImage.h"


// TODO: Implement low memory functions

@interface PropertyResultsViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIAlertView *alertView;
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


#pragma mark -
#pragma mark PropertyResultsViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        
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
    
    [super dealloc];
}

- (IBAction)changeView:(id)sender
{
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
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
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
    [[self view] addSubview:[[self listViewController] tableView]];
    
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
        DebugLog(@"Error saving the deletion in Favorites.");
        
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
