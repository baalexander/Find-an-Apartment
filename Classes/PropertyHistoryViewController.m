#import "PropertyHistoryViewController.h"

#import "PropertyHistory.h"
#import "FindAnApartmentAppDelegate.h"
#import "PropertyListViewController.h"


@interface PropertyHistoryViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@end


@implementation PropertyHistoryViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;


#pragma mark -
#pragma mark PropertyHistoryViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle]))
	{

	}
    
    return self;
}

- (void)dealloc
{
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[self fetchedResultsController] performFetch:nil])
    {
        NSLog(@"Error performing fetch in History viewDidLoad.");
        // TODO: Handle the error.
    }    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSimpleCellId] autorelease];
    }

	PropertyHistory *history = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[[cell textLabel] setText:[[history created] description]];
    
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyHistory *history = [[self fetchedResultsController] objectAtIndexPath:indexPath];
 
    PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
    [listViewController setHistory:history];
    [[self navigationController] pushViewController:listViewController animated:YES];
    [listViewController release];
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

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
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

        NSError *error = nil;
        NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        //WTF: CHECK Do I need this call for results??? 
        if (fetchResults == nil)
        {
            NSLog(@"Error fetching most recent history results.");
            //TODO: Handle the error.
        }
        
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

@end
