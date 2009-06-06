#import "PropertyResultsViewController.h"

#import "FindAnApartmentAppDelegate.h"


//Element name that separates each item in the XML results
static const char *kItemName = "property";


// Class extension for private properties and methods.
@interface PropertyResultsViewController ()
@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) PropertyDetails *details;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, retain) XmlParser *parser;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end

@implementation PropertyResultsViewController

@synthesize history = history_;
@synthesize details = details_;
@synthesize summary = summary_;
@synthesize parser = parser_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *selectedRowIndexPath = [[self tableView] indexPathForSelectedRow];
    if (selectedRowIndexPath != nil)
    {
        [[self tableView] deselectRowAtIndexPath:selectedRowIndexPath animated:NO];
    }
}

// This method will be called repeatedly - once each time the user choses to parse.
- (void)parse:(NSURL *)url
{
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
#pragma mark UITableViewDataSource

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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell to show the book's title
	PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[[cell textLabel] setText:[summary title]];
    [[cell detailTextLabel] setText:[summary subtitle]];
    
	return cell;
}    


#pragma mark -
#pragma mark Core Data objects

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil)
    {
        FindAnApartmentAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:appDelegate.managedObjectContext];
    }
    
    return managedObjectContext_;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ == nil)
    {
        FindAnApartmentAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectModel:appDelegate.managedObjectModel];
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
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
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


#pragma mark <ParserDelegate> Implementation

- (void)parserDidEndParsingData:(XmlParser *)parser
{    
    NSError *error;
    if (![[self managedObjectContext] save:&error])
    {
        NSLog(@"Error saving context.");
        // TODO: Handle the error.
    }
    
    NSLog(@"HISTORY TITLE: %@", [[self history] title]);
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error performing fetch.");
        // TODO: Handle the error.
    }
    
    [[self tableView] reloadData];
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
        NSString *link = [NSString stringWithFormat:@"%@:%@", [[self history] created], value];
        [[self summary] setTitle:link];
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
    NSEntityDescription *resultEntity = [[[self managedObjectModel] entitiesByName] objectForKey: @"PropertyDetails"];
    PropertyDetails *details = [[PropertyDetails alloc] initWithEntity:resultEntity insertIntoManagedObjectContext:[self managedObjectContext]];
    [self setDetails:details];
    [details release];
    
    NSEntityDescription *summaryEntity = [[[self managedObjectModel] entitiesByName] objectForKey: @"PropertySummary"];
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
    NSLog(@"Parser did fail with error.");
    // TODO handle errors as appropriate to your application...
}

@end
