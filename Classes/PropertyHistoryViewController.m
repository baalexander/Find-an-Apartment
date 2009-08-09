#import "PropertyHistoryViewController.h"

#import "PropertyHistory.h"
#import "PropertyCriteria.h"
#import "PropertyListViewController.h"


@interface PropertyHistoryViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyHistoryViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize selectedIndex = selectedIndex_;


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
    [propertyObjectContext_ release];
    
    [super dealloc];
}

//Does a deep copy of Criteria and adds to an autoreleased History object
//Did not name copyCriteriaIntoHistory because having the word "copy" or "new" at the beginning implies a copied object or non-autoreleased object will be returned
+ (PropertyHistory *)historyWithCopyOfCriteria:(PropertyCriteria *)criteria
{
    NSManagedObjectContext *managedObjectContext = [criteria managedObjectContext];
    
    //Deep copies the Criteria. This will prevent conflicts when deleting the History but going back to the criteria page and trying to research. For example, when no results, the History is deleted, not saved, and so is the Criteria. But if the user went one page back and researched and had results, the context would not be able to save since the Criteria was actually deleted from the context.
    NSEntityDescription *criteriaEntity = [NSEntityDescription entityForName:@"PropertyCriteria" inManagedObjectContext:managedObjectContext];
    PropertyCriteria *copyCriteria = [[PropertyCriteria alloc] initWithEntity:criteriaEntity insertIntoManagedObjectContext:managedObjectContext];
    NSDictionary *criteriaAttributes = [criteriaEntity attributesByName];
    for (NSString *key in criteriaAttributes)
    {
        [copyCriteria setValue:[criteria valueForKey:key] forKey:key];
    }

    //Create History object, note the autorelease because needs to be returned
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
    PropertyHistory *history = [[PropertyHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    
    //Sets relationships to the COPY criteria
    [history setCriteria:copyCriteria];
    [copyCriteria release];
    
    //Sets attributes
    NSDate *now = [[NSDate alloc] init];
    [history setCreated:now];
    [now release];
    
    //Deletes old History objects
    [PropertyHistoryViewController deleteOldHistoryObjects:managedObjectContext];
    
    return history;
}

//Keep only the most recent History objects
+ (void)deleteOldHistoryObjects:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
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
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if (fetchResults == nil)
    {
        // Handle the error.
        NSLog(@"Error fetching recent History objects in historyFromCriteria.");
        
        return;
    }
    
    for (NSUInteger i = 9; i < [fetchResults count]; i++)
    {
        PropertyHistory *history = [fetchResults objectAtIndex:i];
        [managedObjectContext deleteObject:history];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:[self propertyObjectContext]];
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
                                                                                                   managedObjectContext:[self propertyObjectContext] 
                                                                                                     sectionNameKeyPath:nil 
                                                                                                              cacheName:@"History"];
        [fetchRequest release];
        [self setFetchedResultsController:fetchedResultsController];
        [fetchedResultsController release];
        
        [[self fetchedResultsController] setDelegate:self];
    }
    
    return fetchedResultsController_;
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Recent Searches"];
    
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
    [[self tableView] reloadData];
    
    [[self tableView] selectRowAtIndexPath:[self selectedIndex] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[self tableView] deselectRowAtIndexPath:[self selectedIndex] animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

static NSString *kSimpleCellId = @"SIMPLE_CELL_ID";


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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kSimpleCellId] autorelease];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    PropertyHistory *history = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[history title]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:[history created]];
    [[cell detailTextLabel] setText:formattedDate];
    [dateFormatter release];
    
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
    
    [self setSelectedIndex:indexPath];
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        //When inserting into History, the most recent search results will be at the top. The default newIndexPath is at the end.
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:[newIndexPath section]];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:firstIndexPath, nil];
        [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [indexPaths release];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [indexPaths release];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert)
    {
        [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [[self tableView] endUpdates];
}

@end
