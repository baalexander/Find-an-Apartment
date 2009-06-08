#import "PropertyMapViewController.h"

#import "PropertyListViewController.h"


//TODO put these in a file shared by List and Maps instead of duplicating
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


@implementation PropertyMapViewController


#pragma mark -
#pragma mark PropertyMapViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self = [super initWithNibName:nibName bundle:nibBundle]))
	{

    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    //Bring up list view
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
        [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:listViewController];
        [listViewController release];
        [[self navigationController] setViewControllers:viewControllers animated:NO];
        [viewControllers release];
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // "Segmented" control to the right
    NSArray *segmentOptions = [[NSArray alloc] initWithObjects:@"list", @"map", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentOptions];
    [segmentOptions release];
    
    //Set selected segment index must come before addTarget, otherwise the action will be called as if the segment was pressed
    [segmentedControl setSelectedSegmentIndex:kMapItem];
	[segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
	[[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
}

@end
