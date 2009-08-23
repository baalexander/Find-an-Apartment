#import "PropertyCitiesViewController.h"

#import "LocationManager.h"
#import "PropertyCriteriaViewController.h"
#import "CityOrPostalCode.h"
#import "SaveAndRestoreConstants.h"


@interface PropertyCitiesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
- (void)pushCriteriaViewControllerWithCity:(CityOrPostalCode *)cityOrZip animated:(BOOL)animated;
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
        [self setTitle:@"City or Zip"];        
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

- (void)pushCriteriaViewControllerWithCity:(CityOrPostalCode *)cityOrZip animated:(BOOL)animated
{
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
    [criteriaViewController setState:[[self state] name]];
    
    //Is it a city or a zip?
    NSRange rangeOfDigit = [[cityOrZip value] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (rangeOfDigit.location == NSNotFound)
    {
        [criteriaViewController setCity:[cityOrZip value]];
    }
    else
    {
        [criteriaViewController setPostalCode:[cityOrZip value]];
    }

    [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:criteriaViewController animated:animated];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark SaveAndRestoreProtocol

- (void)restore
{
    NSString *cityName = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedCity];
    
    if (cityName != nil && [cityName length] > 0)
    {
        NSManagedObjectContext *managedObjectContext = [[self state] managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *cityEntity = [NSEntityDescription entityForName:@"CityOrPostalCode" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:cityEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(value == %@)", cityName];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        
        if (fetchResults != nil && [fetchResults count] > 0)
        {
            CityOrPostalCode *cityOrZip = [fetchResults objectAtIndex:0];
            [self pushCriteriaViewControllerWithCity:cityOrZip animated:NO];
        }
    }    
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
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    if (error != nil)
    {
        NSLog(@"Error performing fetch in states view controller.");
        //TODO: Handle error
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Reset all restore values up to this view controller (does not delete saved State as the State view controller is the parent of this one)
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedCity];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedPostalCode];
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kSavedLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kSavedLatitude];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUsedCoreLocation];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    CityOrPostalCode *cityOrZip;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        cityOrZip = [[self filteredContent] objectAtIndex:[indexPath row]];        
    }
    else
    {
        cityOrZip = [[self fetchedResultsController] objectAtIndexPath:indexPath];        
    }
    [[cell textLabel] setText:[cityOrZip value]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityOrPostalCode *cityOrZip;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        cityOrZip = [[self filteredContent] objectAtIndex:[indexPath row]];
    }
    else
    {
        cityOrZip = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    }
    
    //Saves the selected city for restoring later
    [[NSUserDefaults standardUserDefaults] setObject:[cityOrZip value] forKey:kSavedCity];

    [self pushCriteriaViewControllerWithCity:cityOrZip animated:YES];
}


#pragma mark -
#pragma mark Location Callback

- (void)useCriteria:(PropertyCriteria *)criteria
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUsedCoreLocation];
    
    //Archives the location data for restoring later
    [[NSUserDefaults standardUserDefaults] setDouble:[[criteria longitude] doubleValue] forKey:kSavedLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:[[criteria latitude] doubleValue] forKey:kSavedLatitude];
    [[NSUserDefaults standardUserDefaults] setObject:[criteria state] forKey:kSavedState];
    [[NSUserDefaults standardUserDefaults] setObject:[criteria city] forKey:kSavedCity];
    [[NSUserDefaults standardUserDefaults] setObject:[criteria postalCode] forKey:kSavedPostalCode];
    
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
