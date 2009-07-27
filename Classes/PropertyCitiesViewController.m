#import "PropertyCitiesViewController.h"

#import "LocationManager.h"
#import "PropertyCriteriaViewController.h"
#import "CityOrPostalCode.h"


@interface PropertyCitiesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyCitiesViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize state = state_;
@synthesize locationManager = locationManager_;
@synthesize searchBar = searchBar_;
@synthesize searchDisplayController = searchDisplayController_;
@synthesize filteredContent = filteredContent_;


#pragma mark -
#pragma mark CitiesViewController

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
    [state_ release];
    [searchBar_ release];
    [searchDisplayController_ release];
    [filteredContent_ release];
    
    [super dealloc];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ == nil)
    {
        NSManagedObjectContext *geographyObjectContext = [[self state] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityOrPostalCode" inManagedObjectContext:geographyObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"state == %@", [self state]];
        [fetchRequest setPredicate:fetchPredicate];
        
        NSSortDescriptor *cityDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isCity" ascending:NO];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:cityDescriptor, nameDescriptor, nil];
        [nameDescriptor release];
        [cityDescriptor release];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
        
        // Create and initialize the fetch results controller.
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                   managedObjectContext:geographyObjectContext
                                                                                                     sectionNameKeyPath:@"sectionCharacter" 
                                                                                                              cacheName:@"Cities"];
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
    
    // Search setup
    [self setFilteredContent:[[NSArray alloc] init]];
    [self setSearchDisplayController:[[[UISearchDisplayController alloc]
									 initWithSearchBar:[self searchBar] contentsController:self] autorelease]];
    [[self searchDisplayController] setSearchResultsDataSource:self];
    [[self searchDisplayController] setSearchResultsDelegate:self];
    [[self searchDisplayController] setDelegate:self];
	
	[[self searchBar] setAutocorrectionType:UITextAutocorrectionTypeNo]; // Don't get in the way of user typing.
	[[self searchBar] setAutocapitalizationType:UITextAutocapitalizationTypeNone]; // Don't capitalize each word.
	[[self searchBar] setDelegate:self]; // Become delegate to detect changes in scope.
    
    // Setup the location button
    UIBarButtonItem *locationBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locate.png"]
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:[self locationManager] action:@selector(locateUser)];
    [[self navigationItem] setRightBarButtonItem:locationBtn];
    [locationBtn release];
    [[self locationManager] setLocationCaller:self];
    
    [self setTitle:@"City"];
    
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
    if(tableView == [[self searchDisplayController] searchResultsTableView])
        return 1;
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == [[self searchDisplayController] searchResultsTableView])
        return [[self filteredContent] count];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(tableView == [[self searchDisplayController] searchResultsTableView])
        return @"";
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
    
    CityOrPostalCode *city;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
        city = [[self filteredContent] objectAtIndex:indexPath.row];
    else
        city = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[[city value] description]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityOrPostalCode *city;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
        city = [[self filteredContent] objectAtIndex:indexPath.row];
    else
        city = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
    [criteriaViewController setState:[self state]];
    [criteriaViewController setCity:city];
    [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark Location Callback

- (void)useCriteria:(PropertyCriteria *)criteria
{
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] init];
    [criteriaViewController setCriteria:criteria];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{	
    NSManagedObjectContext *geographyObjectContext = [[self state] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityOrPostalCode" 
                                              inManagedObjectContext:geographyObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@ and value beginswith[cd] %@", [self state], searchText];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *cityDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isCity" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:cityDescriptor, nameDescriptor, nil];
    [nameDescriptor release];
    [cityDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    NSError *error = nil;
    [self setFilteredContent:[geographyObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
    
    if(error)
    {
        NSLog(@"Error filtering content: %@", error);
        // TODO: Handle search error
    }
    [error release];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[[self searchBar] scopeButtonTitles] objectAtIndex:[[self searchBar] selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[[self searchBar] text] scope:
     [[[self searchBar] scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
