#import "PropertyDetailsViewController.h"

#import "PropertyDetailsConstants.h"
#import "PropertyFavoritesViewController.h"
#import "PropertyListEmailerViewController.h"
#import "StringFormatter.h"
#import "PropertyMapViewController.h"
#import "PropertyImage.h"
#import "WebViewController.h"
#import "PropertyImageViewController.h"


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
@synthesize descriptionCell = descriptionCell_;
@synthesize addToFavoritesBtn = addToFavoritesBtn_;
@synthesize selectedIndex = selectedIndex_;


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
    [selectedIndex_ release];
    
    [super dealloc];
}

- (IBAction)previousNext:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedSegment = [segmentedControl selectedSegmentIndex];
    if (selectedSegment == kDetailsPrevious)
    {
        PropertyDetails *details = [[self delegate] detailsPrevious:self];
        [self setDetails:details];
    }
    else if (selectedSegment == kDetailsNext)
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
        [[self addToFavoritesBtn] setEnabled:NO];
        NSLog(@"Added to favorites.");
    }
}

- (BOOL)hasDisclosureIndicator:(NSString *)key
{
    return [key isEqual:kDetailsImages] || [key isEqual:kDetailsLink] || [key isEqual:kDetailsEmail] || [key isEqual:kDetailsLocation];
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
        [locationSection setObject:[[self details] location] forKey:kDetailsLocation];
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
        [financeSection setObject:[StringFormatter formatCurrency:[[self details] price]] forKey:kDetailsPrice];
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
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] squareFeet]] forKey:kDetailsSquareFeet];
    }
    if ([[self details] bedrooms] != nil)
    {
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] bedrooms]] forKey:kDetailsBedrooms];
    }
    if ([[self details] bathrooms] != nil)
    {
        [detailsSection setObject:[StringFormatter formatNumber:[[self details] bathrooms]] forKey:kDetailsBathrooms];
    }    
    if ([[self details] year] != nil)
    {
        [detailsSection setObject:[[[self details] year] stringValue] forKey:kDetailsYear];
    }
    if ([[self details] school] != nil)
    {
        [detailsSection setObject:[[self details] school] forKey:kDetailsSchool];
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
        [contactSection setObject:[[self details] source] forKey:kDetailsSource];
    }
    if ([[self details] email] != nil)
    {
        //TODO: Validate email before adding?
        [contactSection setObject:[[self details] email] forKey:kDetailsEmail];
    }
    if ([[self details] agent] != nil)
    {
        [contactSection setObject:[[self details] agent] forKey:kDetailsAgent];
    }    
    if ([[self details] broker] != nil)
    {
        [contactSection setObject:[[self details] broker] forKey:kDetailsBroker];
    }
    if ([[self details] link] != nil)
    {
        [contactSection setObject:[[self details] link] forKey:kDetailsLink];
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
        [imagesSection setObject:[StringFormatter formatNumber:imageCount] forKey:kDetailsImages];
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
        [descriptionSection setObject:[[self details] details] forKey:kDetailsDescription];
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

// The TTPhotoViewer changes the nav bar and status bar style to translucent back, so it needs to be changed back
- (void)viewWillAppear:(BOOL)animated
{
    [[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
}

// Used solely to animate the deselection of the link cell
- (void)viewDidAppear:(BOOL)animated
{
    [[self tableView] deselectRowAtIndexPath:[self selectedIndex] animated:YES];
}

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
    
    // Disable "Add to Favorites" if the property is already saved
    if([PropertyFavoritesViewController isPropertyAFavorite:[[self details] summary]])
    {
        [[self addToFavoritesBtn] setEnabled:NO];
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
    
    if ([key isEqual:kDetailsLocation])
    {
        return [LocationCell height];
    }
    else if ([key isEqual:kDetailsDescription])
    {
        return [DescriptionCell height];
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
    if ([key isEqual:kDetailsLocation])
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
    
    //Description cell
    if ([key isEqual:kDetailsDescription])
    {        
        static NSString *kDescriptionCell = @"DESCRIPTION_CELL_ID";
        
        [self setDescriptionCell:(DescriptionCell *)[[self tableView] dequeueReusableCellWithIdentifier:kDescriptionCell]];
        if ([self descriptionCell] == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:self options:nil];
        }
        [[[self descriptionCell] textView] setText:detail];
        
        return [self descriptionCell];
    }
    
    //Default cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kSimpleCellId] autorelease];
    }
    
    //Adds disclosure indicator if...
    if ([self hasDisclosureIndicator:key])
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    

    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:detail];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

//Enables/Disables cell for selection based on if selectable
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *details = [[self sectionDetails] objectAtIndex:[indexPath section]];
    NSArray *keys = [details allKeys];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    
    if ([self hasDisclosureIndicator:key])
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *details = [[self sectionDetails] objectAtIndex:[indexPath section]];
    NSArray *keys = [details allKeys];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    NSString *detail = [details objectForKey:key];
    
    if ([key isEqual:kDetailsLocation])
    {
        PropertyMapViewController *mapController = [[PropertyMapViewController alloc] init];
        [mapController setAddress:detail];
        [mapController setSingleAddress:YES];
        [[self navigationController] pushViewController:mapController animated:YES];
        [mapController release];
        [self setSelectedIndex:indexPath];
    }
    
    if ([key isEqual:kDetailsImages])
    {
        // The property photos need to have an order so they are converted to an array from a set
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[detail intValue]];
        for(PropertyImage *image in [[self details] images])
        {
            [images addObject:[image url]];
        }
        
        PropertyImageViewController *imageViewController = [[PropertyImageViewController alloc] initWithImages:images];
        [images release];
        
        [[self navigationController] pushViewController:imageViewController animated:YES];
        [imageViewController release];
        
        [self setSelectedIndex:indexPath];
    }
    
    if ([key isEqual:kDetailsLink])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithAddress:detail];       
        
        // The WebViewController needs to be wrapped in a UINavigationController to get the navigation bar
        // Should probably be its own class, but this way seems more straightforward than keeping track of a 
        // UIWebView inside WebViewController inside another custom class
        UINavigationController *webViewWrapper = [[UINavigationController alloc] initWithRootViewController:webViewController];
        [[webViewWrapper navigationBar] setTintColor:[UIColor blackColor]];
        [webViewController release];
        
        [self presentModalViewController:webViewWrapper animated:YES];
        [self setSelectedIndex:indexPath];
    }
    
    if ([key isEqual:kDetailsEmail])
    {
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        [emailer setMailComposeDelegate:self];
        
        NSArray *toRecipients = [[NSArray alloc] initWithObjects:detail, nil];
        [emailer setToRecipients:toRecipients];
        [toRecipients release];
        
        [self presentModalViewController:emailer animated:YES];
        [emailer release];
    }
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
    
	NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
	[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

@end
