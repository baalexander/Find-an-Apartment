#import "PropertyStatesViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "State.h"
#import "PropertyCitiesViewController.h"
#import "PropertyCriteriaViewController.h"
#import "Locator.h"
#import "SaveAndRestoreConstants.h"


@interface PropertyStatesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyStatesViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize geographyObjectContext = geographyObjectContext_;
@synthesize searchBar = searchBar_;
@synthesize searchDisplayController = searchDisplayController_;
@synthesize filteredContent = filteredContent_;


#pragma mark -
#pragma mark StatesViewController

- (void)dealloc
{
    [fetchedResultsController_ release];
    [propertyObjectContext_ release];
    [geographyObjectContext_ release];
    [searchBar_ release];
    [searchDisplayController_ release];
    [filteredContent_ release];    
    
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
#pragma mark SaveAndRestoreProtocol

- (void)restore
{
    BOOL usedCoreLocation = [[NSUserDefaults standardUserDefaults] boolForKey:kUsedCoreLocation];
    NSString *stateName = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedState];

    //If used Core Location last time, then restore directly to the Criteria view controller with he location details
    if (usedCoreLocation)
    {
        PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
        [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
        [[self navigationController] pushViewController:criteriaViewController animated:NO];
        [criteriaViewController release];
    }
    //If selected a State last time, load citites for the State in the City view controller
    else if (stateName != nil && [stateName length] > 0)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *stateEntity = [NSEntityDescription entityForName:@"State" inManagedObjectContext:[self geographyObjectContext]];
        [fetchRequest setEntity:stateEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", stateName];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchResults = [[self geographyObjectContext] executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchResults != nil && [fetchResults count] > 0)
        {
            State *state = [fetchResults objectAtIndex:0];
            PropertyCitiesViewController *citiesViewController = [[PropertyCitiesViewController alloc] initWithNibName:@"PropertyCitiesView" bundle:nil];
            [citiesViewController setState:state];
            [citiesViewController setPropertyObjectContext:[self propertyObjectContext]];
            [[self navigationController] pushViewController:citiesViewController animated:NO];
            [citiesViewController restore];
            [citiesViewController release];
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
        DebugLog(@"Error performing fetch in states view controller.");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //If view appears, then user must have navigated backward to the view or the first time on the view
    //In any case, can reset all restore values as this is the root view controller
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSavedState];
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
    
    State *state;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        state = [[self filteredContent] objectAtIndex:indexPath.row];
    }
    else
    {
        state = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    }
    [[cell textLabel] setText:[state name]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    State *state;
    if(tableView == [[self searchDisplayController] searchResultsTableView])
    {
        state = [[self filteredContent] objectAtIndex:indexPath.row];
    }
    else
    {
        state = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    }
    
    //Saves the selected state for restoring later
    [[NSUserDefaults standardUserDefaults] setObject:[state name] forKey:kSavedState];
    
    PropertyCitiesViewController *citiesViewController = [[PropertyCitiesViewController alloc] initWithNibName:@"PropertyCitiesView" bundle:nil];
    [citiesViewController setState:state];
    [citiesViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:citiesViewController animated:YES];
    [citiesViewController release];
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
    
    //Goes directly to Criteria view controller
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] init];
    [criteriaViewController setPropertyObjectContext:[self propertyObjectContext]];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"State" 
                                              inManagedObjectContext:[self geographyObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", searchText];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:nameDescriptor];
    [nameDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    [self setFilteredContent:[[self geographyObjectContext] executeFetchRequest:fetchRequest error:&error]];
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
