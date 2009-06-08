#import "PropertyListViewController.h"

#import "FindAnApartmentAppDelegate.h"
#import "PropertyDetailsViewController.h"
#import "PropertyMapViewController.h"


//Element name that separates each item in the XML results
static const char *kItemName = "property";
//Segmented Control items
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


// Class extension for private properties and methods.
@interface PropertyListViewController ()
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain) XmlParser *parser;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end

@implementation PropertyListViewController

@synthesize isParsing = isParsing_;
@synthesize history = history_;
@synthesize details = details_;
@synthesize summary = summary_;
@synthesize parser = parser_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;


#pragma mark -
#pragma mark PropertyListViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle]))
	{
        [self setIsParsing:NO];
	}
    
    return self;
}

- (void)dealloc
{
    [history_ release];
    [details_ release];
    [summary_ release];
    [parser_ release];
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    
	[super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
    //Set the break point only to show the comments above. Delete break point and this comment when read.
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    //Bring up map
    if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        PropertyMapViewController *mapViewController = [[PropertyMapViewController alloc] initWithNibName:@"PropertyMapView" bundle:nil];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
        [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:mapViewController];
        [mapViewController release];
        [[self navigationController] setViewControllers:viewControllers animated:NO];
        [viewControllers release];
        
        //Another option instead of replacing the view controllers is presenting a modal view controller of the map. Not sure about back button though or how to switch back to list. List option could still be a segment controller and just dismiss the modal view controller when pressing "list". Back button could do something similar?
        //[[self navigationController] presentModalViewController:mapViewController animated:YES];
    }
}

// This method will be called repeatedly - once each time the user choses to parse.
- (void)parse:(NSURL *)url
{
    [self setIsParsing:YES];
    
    //Create history entity
    NSEntityDescription *historyEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"PropertyHistory"];
    PropertyHistory *history = [[PropertyHistory alloc] initWithEntity:historyEntity insertIntoManagedObjectContext:[self managedObjectContext]];
    [self setHistory:history];
    [history release];
    [[self history] setCreated:[NSDate date]];
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [self setParser:parser];
    [parser release];
    [[self parser] setDelegate:self];
    [[self parser] startWithUrl:url withItemDelimeter:kItemName];
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

static NSString *kSimpleCellId = @"SIMPLE_CELL_ID";

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSimpleCellId] autorelease];
    }
    
    // Configure the cell to show the book's title
	PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[[cell textLabel] setText:[summary title]];
    [[cell detailTextLabel] setText:[summary subtitle]];
    
	return cell;
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


#pragma mark -
#pragma mark Core Data objects

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil)
    {
        FindAnApartmentAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:[appDelegate managedObjectContext]];
    }
    
    return managedObjectContext_;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ == nil)
    {
        FindAnApartmentAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectModel:[appDelegate managedObjectModel]];
    }
    
    return managedObjectModel_;
}

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        if ([self history] == nil)
        {
            //FIXME: TODO OMG
            //The code below fetches the most recent History. BUT the most recent history may not be the right one. For example, the History view controller passes ANY of the Histories into it!
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:[self managedObjectContext]];
            [fetchRequest setEntity:entity];
            
            //No subentities
            [fetchRequest setIncludesSubentities:NO];
            
            //Sorts so most recent is first
            NSSortDescriptor *createdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:createdDescriptor, nil];
            [createdDescriptor release];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [sortDescriptors release];

            //Only concerned about the most recent
            [fetchRequest setFetchLimit:1];
            
            NSError *error = nil;
            NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            if (fetchResults == nil)
            {
                NSLog(@"Error fetching most recent history results.");
                //TODO: Handle the error.
            }
            
            [self setHistory:[fetchResults objectAtIndex:0]];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        //No subentities
        [fetchRequest setIncludesSubentities:NO];
        
        // Create the sort descriptors array.
        NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:titleDescriptor, nil];
        [titleDescriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        //Search all summaries for the most recent search (summaries with this stored history)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(history = %@)", [self history]];
        [fetchRequest setPredicate:predicate];
        
        // Create and initialize the fetch results controller.
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                   managedObjectContext:[self managedObjectContext] 
                                                                                                     sectionNameKeyPath:nil 
                                                                                                              cacheName:@"Root"];
        [fetchRequest release];
        [self setFetchedResultsController:fetchedResultsController];
        [fetchedResultsController release];
    }
    
	return fetchedResultsController_;
}    


#pragma mark -
#pragma mark <ParserDelegate> Implementation

- (void)parserDidEndParsingData:(XmlParser *)parser
{    
    NSError *error;
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Error saving context.");
        // TODO: Handle the error.
    }

    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error performing fetch.");
        // TODO: Handle the error.
    }
    
    [[self tableView] reloadData];
    
    [self setIsParsing:NO];
}

- (void)parser:(XmlParser *)parser addElement:(NSString *)element withValue:(NSString *)value
{
    //Shared attributes
    if ([element isEqual:@"link"])
    {
        [[self summary] setLink:value];
        [[self details] setLink:value];
    }
    else if ([element isEqual:@"price"])
    {
        [[self summary] setPrice:value];
        [[self details] setPrice:value];
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
        [[self details] setBathrooms:value];
    }
    else if ([element isEqual:@"bedrooms"])
    {
        [[self details] setBedrooms:value];
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
    else if ([element isEqual:@"lot_size"])
    {
        [[self details] setLotSize:value];
    }
    else if ([element isEqual:@"price"])
    {
        [[self details] setPrice:value];
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
        [[self details] setSquareFeet:value];
    }
    else if ([element isEqual:@"year"])
    {
        [[self details] setYear:value];
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    NSEntityDescription *resultEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"PropertyDetails"];
    PropertyDetails *details = [[PropertyDetails alloc] initWithEntity:resultEntity insertIntoManagedObjectContext:[self managedObjectContext]];
    [self setDetails:details];
    [details release];
    
    NSEntityDescription *summaryEntity = [[[self managedObjectModel] entitiesByName] objectForKey:@"PropertySummary"];
    PropertySummary *summary = [[PropertySummary alloc] initWithEntity:summaryEntity insertIntoManagedObjectContext:[self managedObjectContext]];
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
    
    NSLog(@"Parser did fail with error.");
    // TODO: handle errors as appropriate to your application...
}

@end
