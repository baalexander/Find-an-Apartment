#import "PropertyMapViewController.h"

#import "PropertyListViewController.h"


//Segmented Control items. Eventually put in a constants file so List view controller does not have to have a duplicate.
static NSInteger kListItem = 0;
static NSInteger kMapItem = 1;


@implementation PropertyMapViewController

@synthesize history = history_;
@synthesize mapView = mapView_;


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
    [history_ release];
    [mapView_ release];
    
    [super dealloc];
}

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    //Bring up list view. Releases this view.
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        //FIXME: What if called from the Favorites view controller? Then needs to load PropertyFavoritesView
        PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
        [listViewController setHistory:[self history]];
        
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
    
    //Segmented control
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
    
    // Center the map based on the user's input
    [self centerMap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
}


//PropertyDetailsDelegate is used by Property Details view controller's segment control for previous/next
#pragma mark -
#pragma mark PropertyDetailsDelegate

- (NSInteger)detailsIndex:(PropertyDetailsViewController *)details
{
    return -1;
}

- (NSInteger)detailsCount:(PropertyDetailsViewController *)details
{
    return -1;
}

- (PropertyDetails *)detailsPrevious:(PropertyDetailsViewController *)details
{
    return nil;
}

- (PropertyDetails *)detailsNext:(PropertyDetailsViewController *)details
{
    return nil;
}


#pragma mark -
#pragma mark Map Setup

- (void)centerMap
{
    CLLocationCoordinate2D center;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    if([[[self history] criteria] coordinates] != nil)
    {
        NSArray *coords = [[[[self history] criteria] coordinates] componentsSeparatedByString:@","];
        center.latitude = [[coords objectAtIndex:0] doubleValue];
        center.longitude = [[coords objectAtIndex:1] doubleValue];
        
    }
    else if([[[self history] criteria] street] != nil)
    {
        if([[[self history] criteria] postalCode] != nil)
        {
            
        }
        else
        {
            
        }
    }
    else if([[[self history] criteria] city] != nil)
    {
        
    }
    else
    {
        
    }
    
    region.center = center;
    region.span = span;
    [[self mapView] setRegion:region];
    [[self mapView] setCenterCoordinate:center animated:YES];
}

@end
