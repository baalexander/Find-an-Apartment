#import "PropertyStatesViewController.h"

#import "State.h"
#import "PropertyCitiesViewController.h"


@interface PropertyStatesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyStatesViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize mainObjectContext = mainObjectContext_;
@synthesize geographyObjectContext = geographyObjectContext_;


#pragma mark -
#pragma mark StatesViewController

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
    [geographyObjectContext_ release];
    
    [super dealloc];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"State" inManagedObjectContext:[self geographyObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
        [nameDescriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        // Create and initialize the fetch results controller.
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                   managedObjectContext:[self geographyObjectContext] 
                                                                                                     sectionNameKeyPath:@"sectionCharacter"
                                                                                                              cacheName:@"States"];
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
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    if (error != nil)
    {
        NSLog(@"Error performing fetch in states view controller.");
        //TODO: Handle error
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [[sectionInfo name] substringToIndex:(NSUInteger)1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSimpleCellId] autorelease];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    State *state = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[[state name] description]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    State *state = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    PropertyCitiesViewController *citiesViewController = [[PropertyCitiesViewController alloc] initWithNibName:@"PropertyCitiesView" bundle:nil];
    [citiesViewController setState:state];
    [citiesViewController setMainObjectContext:[self mainObjectContext]];
    [[self navigationController] pushViewController:citiesViewController animated:YES];
    [citiesViewController release];
}

@end
