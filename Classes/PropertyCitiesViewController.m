#import "PropertyCitiesViewController.h"

#import "LocationManager.h"
#import "PropertyCriteriaViewController.h"
#import "CityOrPostalCode.h"


@interface PropertyCitiesViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation PropertyCitiesViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize mainObjectContext = mainObjectContext_;
@synthesize state = state_;
@synthesize locationManager = locationManager_;


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
    [locationManager_ release];
    [fetchedResultsController_ release];
    [mainObjectContext_ release];
    [state_ release];
    
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
    
    // Setup the location button
    UIBarButtonItem *locationBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"locate.png"]
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:[self locationManager] action:@selector(locateUser)];
    self.navigationItem.rightBarButtonItem = locationBtn;
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
    
    CityOrPostalCode *city = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[cell textLabel] setText:[[city value] description]];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityOrPostalCode *city = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
    [criteriaViewController setState:[self state]];
    [criteriaViewController setCity:city];
    [criteriaViewController setMainObjectContext:[self mainObjectContext]];
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

@end
