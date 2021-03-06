#import "PropertySearchSourcesViewController.h"

#import "PropertyCriteriaConstants.h"


@interface PropertySearchSourcesViewController ()
@property (nonatomic, retain) NSArray *choices;
@end


@implementation PropertySearchSourcesViewController

@synthesize criteria = criteria_;
@synthesize choices = choices_;


#pragma mark -
#pragma mark PropertySourceChoicesViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        NSArray *choices = [[NSArray alloc] initWithObjects:kPropertyCriteriaGoogleBase, kPropertyCriteriaTrulia, nil];
        [self setChoices:choices];
        [choices release];
    }
    
    return self;
}

- (void)dealloc
{
    [criteria_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark UITableViewDataSource

static NSString *kChoiceCellId = @"CHOICE_CELL_ID";


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self choices] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kChoiceCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChoiceCellId] autorelease];
    }
    
    NSString *choice = [[self choices] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:choice];
    
    //Adds checkmark if the chosen choice
    if ([choice isEqual:[[self criteria] searchSource]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Unchecks previously selected cell
    NSString *previousChoice = [[self criteria] searchSource];
    NSInteger indexOfPreviouslyChosen = [[self choices] indexOfObject:previousChoice];    
    NSIndexPath *previousSelectionIndexPath = [NSIndexPath indexPathForRow:indexOfPreviouslyChosen inSection:0];
    [[tableView cellForRowAtIndexPath:previousSelectionIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    
    //Checks selected cell
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];    
    
    //Update the choice in the entity
    [[self criteria] setSearchSource:[[self choices] objectAtIndex:[indexPath row]]];

    //Google Base and Trulia have different default searches.
    if ([[[self criteria] searchSource] isEqual:kPropertyCriteriaTrulia])
    {
        [[self criteria] setSortBy:kPropertyCriteriaSortByBestMatch];
    }
    else if ([[[self criteria] searchSource] isEqual:kPropertyCriteriaGoogleBase])
    {
        [[self criteria] setSortBy:kPropertyCriteriaSortByDistance];
    }
    
    //Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
