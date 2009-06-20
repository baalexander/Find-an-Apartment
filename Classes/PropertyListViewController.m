#import "PropertyListViewController.h"

#import "PropertyCriteria.h"
#import "PropertyDetailsViewController.h"
#import "PropertyMapViewController.h"


//Element name that separates each item in the XML results
static const char *kItemName = "property";
//Segmented Control items
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


// Class extension for private properties and methods.
@interface PropertyListViewController ()
@property (nonatomic, retain) XmlParser *parser;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain, readwrite) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PropertyListViewController

@synthesize tableView = tableView_;
@synthesize parser = parser_;
@synthesize distance = distance_;
@synthesize isParsing = isParsing_;
@synthesize history = history_;
@synthesize details = details_;
@synthesize summary = summary_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize summaryCell = summaryCell_;


#pragma mark -
#pragma mark PropertyListViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle]))
	{
        [self setDistance:0];
        [self setIsParsing:NO];
	}
    
    return self;
}

- (void)dealloc
{
    [tableView_ release];
    [history_ release];
    [details_ release];
    [summary_ release];
    [parser_ release];
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
        [mapViewController setHistory:[self history]];
        
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
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [self setParser:parser];
    [parser release];
    [[self parser] setDelegate:self];
    [[self parser] startWithUrl:url withItemDelimeter:kItemName];
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
}


#pragma mark -
#pragma mark UITableViewDataSource

//This must match the identifier of in the Xib. Otherwise, will never reuse a cell.
static NSString *kSummaryCellId = @"SUMMARY_CELL_ID";


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsController] sections] count];
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    NSInteger numberOfRows = 0;
	
    if ([[[self fetchedResultsController] sections] count] > 0) {
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
    
    //Formats NSNumber as currency with no cents
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMinimumFractionDigits:0];
    NSString *price = [formatter stringFromNumber:[summary price]];
    [formatter release];
    [[[self summaryCell] price] setText:price];
    
    return [self summaryCell];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Gets result from relationship with summary
    PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    PropertyDetails *details = [summary details];    
    
    PropertyDetailsViewController *detailsViewController = [[PropertyDetailsViewController alloc] initWithNibName:@"PropertyDetailsView" bundle:nil];
    [detailsViewController setDetails:details];
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
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
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    [self setIsParsing:NO];
    
    if ([[[self history] summaries] count] == 0)
    {
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

- (void)parser:(XmlParser *)parser addElement:(NSString *)element withValue:(NSString *)value
{
    if (value == nil || [value length] == 0)
    {
        return;
    }
    
    //Shared attributes
    if ([element isEqual:@"link"])
    {
        [[self summary] setLink:value];
        [[self details] setLink:value];
    }
    else if ([element isEqual:@"price"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[value integerValue]];
        [[self summary] setPrice:number];
        [[self details] setPrice:number];
        [number release];
    }
    //Summary attributes
    else if ([element isEqual:@"title"])
    {
        [[self summary] setTitle:value];
    }
    else if ([element isEqual:@"subtitle"])
    {
        [[self summary] setSubtitle:value];
    }
    else if ([element isEqual:@"summary"])
    {
        [[self summary] setSummary:value];
    }
    //Result attributes
    else if ([element isEqual:@"agent"])
    {
        [[self details] setAgent:value];
    }        
    else if ([element isEqual:@"bathrooms"])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[value floatValue]];
        [[self details] setBathrooms:number];
        [number release];
    }
    else if ([element isEqual:@"bedrooms"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[value integerValue]];
        [[self details] setBedrooms:number];
        [number release];
    }
    else if ([element isEqual:@"broker"])
    {
        [[self details] setBroker:value];
    }
    else if ([element isEqual:@"copright"])
    {
        [[self details] setCopyright:value];
    }
    else if ([element isEqual:@"copyright_link"])
    {
        [[self details] setCopyrightLink:value];
    }
    else if ([element isEqual:@"description"])
    {
        [[self details] setDetails:value];
    }
    else if ([element isEqual:@"email"])
    {
        [[self details] setEmail:value];
    }
    else if ([element isEqual:@"image_link"])
    {
        [[self details] setImageLink:value];
    }
    else if ([element isEqual:@"link"])
    {
        [[self details] setLink:value];
    }
    else if ([element isEqual:@"location"])
    {
        [[self details] setLocation:value];
    }
    else if ([element isEqual:@"school"])
    {
        [[self details] setSchool:value];
    }
    else if ([element isEqual:@"source"])
    {
        [[self details] setSource:value];
    }
    else if ([element isEqual:@"square_feet"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[value integerValue]];
        [[self details] setSquareFeet:number];
        [number release];
    }
    else if ([element isEqual:@"year"])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[value integerValue]];
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
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error finding results" 
														 message:[error localizedDescription] 
														delegate:self 
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

@end
