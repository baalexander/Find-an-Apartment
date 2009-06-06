#import "PropertyCitiesViewController.h"

#import "PropertyCriteriaViewController.h"


@implementation PropertyCitiesViewController

@synthesize state = state_;


#pragma mark -
#pragma mark CitiesViewController

- (void)dealloc
{
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"City"];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setText:@"Austin"];
    
	return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyCriteriaViewController *criteriaViewController = [[PropertyCriteriaViewController alloc] initWithNibName:@"PropertyCriteriaView" bundle:nil];
    [criteriaViewController setState:[self state]];
    [criteriaViewController setCity:@"Austin"];
    [[self navigationController] pushViewController:criteriaViewController animated:YES];
    [criteriaViewController release];
} 

@end
