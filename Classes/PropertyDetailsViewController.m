#import "PropertyDetailsViewController.h"

#import "PropertyFavoritesViewController.h"
#import "PropertyListEmailerViewController.h"
#import "StringFormatter.h"

static NSInteger kPrevious = 0;
static NSInteger kNext = 1;


@interface PropertyDetailsViewController ()
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@property (nonatomic, retain) NSMutableArray *sectionDetails;
@end

@implementation PropertyDetailsViewController

@synthesize delegate = delegate_;
@synthesize tableView = tableView_;
@synthesize details = details_;
@synthesize sectionTitles = sectionTitles_;
@synthesize sectionDetails = sectionDetails_;
@synthesize locationCell = locationCell_;


#pragma mark -
#pragma mark PropertyDetailsViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [tableView_ release];
    [details_ release];
    [sectionTitles_ release];
    [sectionDetails_ release];
    [locationCell_ release];
    
    [super dealloc];
}

- (IBAction)previousNext:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedSegment = [segmentedControl selectedSegmentIndex];
    if (selectedSegment == kPrevious)
    {
        PropertyDetails *details = [[self delegate] detailsPrevious:self];
        [self setDetails:details];
    }
    else if (selectedSegment == kNext)
    {
        PropertyDetails *details = [[self delegate] detailsNext:self];
        [self setDetails:details];        
    }
    
    NSString *title = [[NSString alloc] initWithFormat:@"%d of %d", [[self delegate] detailsIndex:self] + 1, [[self delegate] detailsCount:self]];
    [self setTitle:title];
    [title release];
    
    [[self tableView] reloadData];
}

- (void)share:(id)sender
{
    PropertyListEmailerViewController *listEmailer = [[PropertyListEmailerViewController alloc] init];
    [listEmailer setMailComposeDelegate:self];
    
    PropertySummary *summary = [[self details] summary];
    NSArray *properties = [[NSArray alloc] initWithObjects:summary, nil];
    [listEmailer setProperties:properties];
    [properties release];
    
    [self presentModalViewController:listEmailer animated:YES];
    [listEmailer release];
}

- (void)addToFavorites:(id)sender
{
    PropertySummary *summary = [[self details] summary];
    if (![PropertyFavoritesViewController addCopyOfProperty:summary])
    {
        //TODO: Show alert
        NSLog(@"Already in favorites.");
    }
    else
    {
        NSLog(@"Added to favorites.");
    }
}

- (void)setDetails:(PropertyDetails *)details
{
    //Retain/release
    [details retain];
    [details_ release];
    details_ = details;
    
    //Set table view layout based on values in Details
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    [self setSectionTitles:sectionTitles];
    [sectionTitles release];
    
    NSMutableArray *sectionDetails = [[NSMutableArray alloc] init];
    [self setSectionDetails:sectionDetails];
    [sectionDetails release];
    
    //Location section
    NSMutableDictionary *locationSection = [[NSMutableDictionary alloc] init];
    if ([[self details] location] != nil)
    {
        [locationSection setObject:[[self details] location] forKey:@"location"];
    }
    if ([locationSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Location"];
        [[self sectionDetails] addObject:locationSection];
    }
    [locationSection release];
    
    //Finance section
    NSMutableDictionary *financeSection = [[NSMutableDictionary alloc] init];
    if ([[self details] price] != nil)
    {
        [financeSection setObject:[StringFormatter formatCurrency:[[self details] price]] forKey:@"price"];
    }
    if ([financeSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Finance"];
        [[self sectionDetails] addObject:financeSection];
    }
    [financeSection release];
    
    //Details section
    NSMutableDictionary *detailsSection = [[NSMutableDictionary alloc] init];
    if ([[self details] squareFeet] != nil)
    {
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] squareFeet]] forKey:@"sq feet"];
    }
    if ([[self details] bedrooms] != nil)
    {
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] bedrooms]] forKey:@"bedrooms"];
    }
    if ([[self details] bathrooms] != nil)
    {
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] bathrooms]] forKey:@"bathrooms"];
    }    
    if ([[self details] year] != nil)
    {
        [detailsSection setObject:[[[self details] year] stringValue] forKey:@"year"];
    }
    if ([[self details] school] != nil)
    {
        [detailsSection setObject:[[self details] school] forKey:@"school"];
    }        
    if ([detailsSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Details"];
        [[self sectionDetails] addObject:detailsSection];
    }
    [detailsSection release];
    
    //Contact section
    NSMutableDictionary *contactSection = [[NSMutableDictionary alloc] init];
    if ([[self details] source] != nil)
    {
        [contactSection setObject:[[self details] source] forKey:@"source"];
    }
    if ([[self details] email] != nil)
    {
        //TODO: Validate email before adding?
        [contactSection setObject:[[self details] email] forKey:@"email"];
    }
    if ([[self details] agent] != nil)
    {
        [contactSection setObject:[[self details] agent] forKey:@"agent"];
    }    
    if ([[self details] broker] != nil)
    {
        [contactSection setObject:[[self details] broker] forKey:@"broker"];
    }
    if ([[self details] link] != nil)
    {
        [contactSection setObject:[[self details] link] forKey:@"link"];
    }
    if ([[self details] copyright] != nil)
    {
        [contactSection setObject:[[self details] copyright] forKey:@"copyright"];
    }        
    if ([contactSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Source"];
        [[self sectionDetails] addObject:contactSection];
    }
    [contactSection release];
    
    //Media section
    NSMutableDictionary *imagesSection = [[NSMutableDictionary alloc] init];
    NSSet *images = [[self details] images];
    if (images != nil && [images count] > 0)
    {
        NSNumber *imageCount = [[NSNumber alloc] initWithUnsignedInteger:[images count]];
        [imagesSection setObject:[StringFormatter formatNumber:imageCount] forKey:@"images"];
        [imageCount release];
    }
    if ([imagesSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Media"];
        [[self sectionDetails] addObject:imagesSection];
    }
    [imagesSection release];

    //Description section
    NSMutableDictionary *descriptionSection = [[NSMutableDictionary alloc] init];
    if ([[self details] details] != nil)
    {
        [descriptionSection setObject:[[self details] details] forKey:@"description"];
    }
    if ([descriptionSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Description"];
        [[self sectionDetails] addObject:descriptionSection];
    }
    [descriptionSection release];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sets title to: "1 of 50"
    NSString *title = [[NSString alloc] initWithFormat:@"%d of %d", [[self delegate] detailsIndex:self] + 1, [[self delegate] detailsCount:self]];
    [self setTitle:title];
    [title release];    
    
    //Segmented control to the right
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"up.png"],
                                             [UIImage imageNamed:@"down.png"],
                                             nil]];
	[segmentedControl addTarget:self action:@selector(previousNext:) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl setMomentary:YES];
    
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
	[[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];
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
    return [[self sectionTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self sectionTitles] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *details = [[self sectionDetails] objectAtIndex:section];

    return [[details allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *details = [[self sectionDetails] objectAtIndex:[indexPath section]];
    NSArray *keys = [details allKeys];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    
    if ([key isEqual:@"location"])
    {
        return [LocationCell height];
    }
    
    //Returns default row height
    return [[self tableView] rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    NSDictionary *details = [[self sectionDetails] objectAtIndex:[indexPath section]];
    NSArray *keys = [details allKeys];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    NSString *detail = [details objectForKey:key];
    
    //Location cell
    if ([key isEqual:@"location"])
    {        
        static NSString *kLocationCell = @"LOCATION_CELL_ID";
        
        [self setLocationCell:(LocationCell *)[[self tableView] dequeueReusableCellWithIdentifier:kLocationCell]];
        if ([self locationCell] == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
        }
        [[self locationCell] setLocation:detail];
        
        return [self locationCell];
    }
    
    //Default cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kSimpleCellId] autorelease];
    }
    
    //Adds disclosure indicator if...
    if ([key isEqual:@"images"])
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:detail];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}    


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

@end
