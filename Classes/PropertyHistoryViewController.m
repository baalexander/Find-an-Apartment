#import "PropertyHistoryViewController.h"

#import "PropertyHistory.h"
#import "PropertyListViewController.h"


@interface PropertyHistoryViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyHistoryViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize mainObjectContext = mainObjectContext_;


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
    [mainObjectContext_ release];
    
	[super dealloc];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:[self mainObjectContext]];
        [fetchRequest setEntity:entity];
        
        //Sorts so most recent is first
        NSSortDescriptor *createdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:createdDescriptor, nil];
        [createdDescriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        //Ignores Favorites history
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isFavorite == NO)"];
        [fetchRequest setPredicate:predicate];
        
        // Create and initialize the fetch results controller.
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                   managedObjectContext:[self mainObjectContext] 
                                                                                                     sectionNameKeyPath:nil 
                                                                                                              cacheName:@"History"];
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
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
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

@end
