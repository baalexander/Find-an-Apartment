#import "PropertyListViewController.h"

#import "PropertyImage.h"
#import "PropertyCriteria.h"
#import "PropertyDetailsViewController.h"
#import "PropertyMapViewController.h"
#import "StringFormatter.h"


//Element name that separates each item in the XML results
static const char *kItemName = "property";
//Segmented Control items
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


// Class extension for private properties and methods.
@interface PropertyListViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation PropertyListViewController

@synthesize tableView = tableView_;
@synthesize operationQueue = operationQueue_;
@synthesize distance = distance_;
@synthesize isParsing = isParsing_;
@synthesize history = history_;
@synthesize details = details_;
@synthesize summary = summary_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize summaryCell = summaryCell_;
@synthesize selectedIndex = selectedIndex_;
@synthesize selectedIndexPath = selectedIndexPath_;


#pragma mark -
#pragma mark PropertyListViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        [self setDistance:0];
        [self setIsParsing:NO];
        [self setSelectedIndex:0];
    }
    
    return self;
}

- (void)dealloc
{
    [tableView_ release];
    [operationQueue_ release];
    [history_ release];
    [details_ release];
    [summary_ release];
    [selectedIndexPath_ release];
    [fetchedResultsController_ release];
    
    [super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;

    //Bring up map
    if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        PropertyMapViewController *mapViewController = [[PropertyMapViewController alloc] initWithNibName:@"PropertyMapView" bundle:nil];
        [mapViewController geocodePropertiesFromHistory:[self history]];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
        [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:mapViewController];
        [mapViewController release];
        [[self navigationController] setViewControllers:viewControllers animated:NO];
        [viewControllers release];
        
        //Another option instead of replacing the view controllers is presenting a modal view controller of the map. Not sure about back button though or how to switch back to list. List option could still be a segment controller and just dismiss the modal view controller when pressing "list". Back button could do something similar?
        //[[self navigationController] presentModalViewController:mapViewController animated:YES];
    }
}

- (void)parse:(NSURL *)url
{
    [self setIsParsing:YES];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [self setOperationQueue:operationQueue];
    [operationQueue release];
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [parser setDelegate:self];
    [parser setUrl:url];
    [parser setItemDelimiter:kItemName];
    
    //Add the Parser to an operation queue for background processing (works on a separate thread)
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
            NSLog(@"Error: History is nil in fetched results controller in List view controller.");
        }
        
        //Get managed object context from History
        NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        //Create the sort descriptors array based on the users sort by selection.
        PropertyCriteria *criteria = [[self history] criteria];
        NSSortDescriptor *descriptor;
        //TODO: Move these strings somewhere so Criteria, Url Constructor, and this don't have duplicated hardcoded strings
        if ([[criteria sortBy] isEqual:@"price (low to high)"])
        {
            descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        }
        else if ([[criteria sortBy] isEqual:@"price (high to low)"])
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
    
    //If fetched objects is nil and not currently parsing results, the call perform fetch to get the most recent results. This would happen when switching from Map to List view. If the parse function already performed, then it has retrieved the results. This very much assumes that the parse function is being called before the view is loading.
    if (![self isParsing] && [[self fetchedResultsController] fetchedObjects] == nil)
    {
        if (![[self fetchedResultsController] performFetch:nil])
        {
            NSLog(@"Error performing fetch in viewDidLoad.");
            // TODO: Handle the error.
        }        
    }

    //Segmented control
    NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
    [segmentOptions release];
    
    //Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
    [segmentedControl setSelectedSegmentIndex:kListItem];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    [[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedRowIndexPath = [[self tableView] indexPathForSelectedRow];
    if (selectedRowIndexPath != nil)
    {
        [[self tableView] deselectRowAtIndexPath:selectedRowIndexPath animated:NO];
    }
    
    // Reselect the previously selected cell
    [[self tableView] selectRowAtIndexPath:[self selectedIndexPath] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

// Deselect the previously selected cell
- (void)viewDidAppear:(BOOL)animated
{
    [[self tableView] deselectRowAtIndexPath:[self selectedIndexPath] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Cancels any operations in the queue. This is for when pressing the back button and dismissing the view controller. This prevents the parser from still running and failing when calling its delegate.
    [[self operationQueue] cancelAllOperations];
}


#pragma mark -
#pragma mark UITableViewDataSource

//This must match the identifier of in the Xib. Otherwise, will never reuse a cell.
static NSString *kSummaryCellId = @"SUMMARY_CELL_ID";


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsController] sections] count];
    
    if (count == 0)
    {
        count = 1;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSInteger numberOfRows = 0;
    
    if ([[[self fetchedResultsController] sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSummaryCell:(SummaryCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryCellId]];
    if ([self summaryCell] == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
    }

    //Configures cell with Summary data
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[[self summaryCell] title] setText:[summary title]];
    [[[self summaryCell] subtitle] setText:[summary subtitle]];
    [[[self summaryCell] summary] setText:[summary summary]];
    
    NSString *price = [StringFormatter formatCurrency:[summary price]];
    [[[self summaryCell] price] setText:price];
    
    return [self summaryCell];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedIndex:[indexPath row]];
    
    //Gets result from relationship with summary
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    PropertyDetails *details = [summary details];   
    
    PropertyDetailsViewController *detailsViewController = [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView" bundle:nil];
    [detailsViewController setDelegate:self];
    [detailsViewController setDetails:details];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
    
    [self setSelectedIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark PropertyDetailsDelegate

- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details
{
    return [self selectedIndex];
}

- (NSInteger)detailsCount:(PropertyDetailsViewController *)details
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:0];

    return [sectionInfo numberOfObjects];
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self selectedIndex] inSection:0];
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self selectedIndex] inSection:0];
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    return [summary details];
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
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"No properties found." 
                                                            delegate:self 
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
        
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [[self history] managedObjectContext];
    
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Error saving context.");
        // TODO: Handle the error.
    }

    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error performing fetch.");
        // TODO: Handle the error.
    }

    [[self tableView] reloadData];
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
    
    //Sets distance. Assume results are ordered by ascending distance. This keeps track of that in the summary for sorting since the results are stored in an unordered set.
    NSNumber *distance = [[NSNumber alloc] initWithInteger:[self distance]];
    [[self summary] setDistance:distance];
    [distance release];
    [self setDistance:[self distance] + 1];
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
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error finding results" 
                                                         message:[error localizedDescription] 
                                                        delegate:self 
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

@end
