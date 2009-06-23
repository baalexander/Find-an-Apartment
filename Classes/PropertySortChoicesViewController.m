#import "PropertySortChoicesViewController.h"

#import "PropertyCriteriaConstants.h"

@interface PropertySortChoicesViewController ()
@property (nonatomic, retain) NSArray *choices;
@end


@implementation PropertySortChoicesViewController

@synthesize criteria = criteria_;
@synthesize choices = choices_;


#pragma mark -
#pragma mark PropertySortChoicesViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        NSArray *choices = [[NSArray alloc] initWithObjects:kCriteriaSortByPriceAscending, kCriteriaSortByPriceDescending, kCriteriaSortByDistance, nil];
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
    if ([choice isEqual:[[self criteria] sortBy]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Unchecks previously selected cell
    NSString *previousChoice = [[self criteria] sortBy];
    NSInteger indexOfPreviouslyChosen = [[self choices] indexOfObject:previousChoice];    
    NSIndexPath *previousSelectionIndexPath = [NSIndexPath indexPathForRow:indexOfPreviouslyChosen inSection:0];
    [[tableView cellForRowAtIndexPath:previousSelectionIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    
    //Checks selected cell
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];    
    
    //Update the choice in the entity
    [[self criteria] setSortBy:[[self choices] objectAtIndex:[indexPath row]]];
    
    //Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
