#import "PropertyCitiesViewController.h"

#import "Locator.h"
#import "PropertyCriteriaViewController.h"
#import "City.h"
#import "SaveAndRestoreConstants.h"


@interface PropertyCitiesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyCitiesViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize state = state_;
@synthesize searchBar = searchBar_;
@synthesize searchDisplayController = searchDisplayController_;
@synthesize filteredContent = filteredContent_;


#pragma mark -
#pragma mark CitiesViewController

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
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:geographyObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"state == %@", [self state]];
        [fetchRequest setPredicate:fetchPredicate];

        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
        [nameDescriptor release];
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
#pragma mark SaveAndRestoreProtocol

- (void)restore
{
    NSString *city = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedCity];
    NSString *postalCode = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedPostalCode];
    
    //Determines if user exited on the Cities view controller or one after
    if ((city != nil && [city length] > 0) || (postalCode != nil && [postalCode length] > 0))
    {
        PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
        [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
        [[self navigationController] pushViewController:criteriaViewController animated:NO];
        [criteriaViewController release];
    }    
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"City"];

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
    [[Locator sharedInstance] setDelegate:self];
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locate.png"]
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:[Locator sharedInstance] action:@selector(locate)];
    [[self navigationItem] setRightBarButtonItem:locationButton];
    [locationButton release];
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    if (error != nil)
    {
        DebugLog(@"Error performing fetch in Cities view controller.");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Reset all restore values up to this view controller (does not delete saved State as the State view controller is the parent of this one)
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedCity];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedPostalCode];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedStreet];
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kSavedLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kSavedLatitude];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUsedCoreLocation];
}


#pragma mark -
#pragma mark UITableViewDataSource

static NSString *kSimpleCellId = @"SIMPLE_CELL_ID";


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        return 1;        
    }

    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        return [[self filteredContent] count];        
    }

    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        return @"";        
    }

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
    
    City *city;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        city = [[self filteredContent] objectAtIndex:[indexPath row]];        
    }
    else
    {
        city = [[self fetchedResultsController] objectAtIndexPath:indexPath];        
    }
    [[cell textLabel] setText:[city name]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *city;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        city = [[[self filteredContent] objectAtIndex:[indexPath row]] name];
    }
    else
    {
        city = [[[self fetchedResultsController] objectAtIndexPath:indexPath] name];
    }

    //Saves selected value as city
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:kSavedCity];

    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
    [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark LocatorDelegate

- (void)locator:(Locator *)locator setLocation:(Location *)location
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUsedCoreLocation];
    
    //Archives the location data for restoring later
    CLLocationCoordinate2D coordinate = [location coordinate];
    [[NSUserDefaults standardUserDefaults] setDouble:coordinate.longitude forKey:kSavedLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:coordinate.latitude forKey:kSavedLatitude];
    [[NSUserDefaults standardUserDefaults] setObject:[location state] forKey:kSavedState];
    [[NSUserDefaults standardUserDefaults] setObject:[location city] forKey:kSavedCity];
    [[NSUserDefaults standardUserDefaults] setObject:[location postalCode] forKey:kSavedPostalCode];
    [[NSUserDefaults standardUserDefaults] setObject:[location street] forKey:kSavedStreet];
    
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] init];
    [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{	
    NSManagedObjectContext *geographyObjectContext = [[self state] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" 
                                              inManagedObjectContext:geographyObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@ and name beginswith[cd] %@", [self state], searchText];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
    [nameDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    NSError *error = nil;
    [self setFilteredContent:[geographyObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
    
    if (error)
    {
        DebugLog(@"Error filtering content: %@", error);
    }
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
