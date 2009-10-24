#import "PropertyDetailsViewController.h"

#import "PropertyDetailsConstants.h"
#import "PropertyFavoritesViewController.h"
#import "PropertyListEmailerViewController.h"
#import "StringFormatter.h"
#import "PropertyMapViewController.h"
#import "PropertyImage.h"
#import "WebViewController.h"
#import "ImagesViewController.h"

#ifdef HOME_FINDER
    #import "MortgageCriteriaViewController.h"
#endif


@interface PropertyDetailsViewController ()
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@property (nonatomic, retain) NSMutableArray *sectionDetails;
@end

@implementation PropertyDetailsViewController

@synthesize tableView = tableView_;
@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyIndex = propertyIndex_;
@synthesize details = details_;
@synthesize sectionTitles = sectionTitles_;
@synthesize sectionDetails = sectionDetails_;
@synthesize locationCell = locationCell_;
@synthesize descriptionCell = descriptionCell_;
@synthesize addToFavoritesButton = addToFavoritesButton_;

#ifdef HOME_FINDER
@synthesize truliaCopyrightCell = truliaCopyrightCell_;
@synthesize providedByTruliaCell = providedByTruliaCell_;
#endif


#pragma mark -
#pragma mark PropertyDetailsViewController

- (void)dealloc
{
    [tableView_ release];
    [details_ release];
    [sectionTitles_ release];
    [sectionDetails_ release];
    [locationCell_ release];
    [descriptionCell_ release];
    
#ifdef HOME_FINDER
    [truliaCopyrightCell_ release];
    [providedByTruliaCell_ release];
#endif
    
    [super dealloc];
}

- (IBAction)previousNext:(id)sender
{
    NSInteger propertyCount = [[self propertyDataSource] numberOfPropertiesInView:[self tableView]];
    
    // Gets the previous or next property
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedSegment = [segmentedControl selectedSegmentIndex];
    if (selectedSegment == kDetailsPrevious)
    {
        // Wraps the property index around if at the first property already
        if ([self propertyIndex] > 0)
        {
            [self setPropertyIndex:[self propertyIndex] - 1];
        }
        else
        {
            [self setPropertyIndex:propertyCount - 1];
        }
    }
    else if (selectedSegment == kDetailsNext)
    {
        // Wraps the property index around if at the last property already
        if ([self propertyIndex] < propertyCount - 1)
        {
            [self setPropertyIndex:[self propertyIndex] + 1];
        }
        else
        {
            [self setPropertyIndex:0];
        }
    }
    
    PropertySummary *property = [[self propertyDataSource] view:[self tableView] propertyAtIndex:[self propertyIndex]];
    PropertyDetails *details = [property details];
    [self setDetails:details];
    
    // Updates the title 
    NSString *title = [[NSString alloc] initWithFormat:@"%d of %d", [self propertyIndex] + 1, propertyCount];
    [self setTitle:title];
    [title release];  
    
    // Disable "Add to Favorites" if the property is already saved
    if([PropertyFavoritesViewController isPropertyAFavorite:[[self details] summary]])
    {
        [[self addToFavoritesButton] setEnabled:NO];
    }
    //Renables button if not already saved
    else
    {
        [[self addToFavoritesButton] setEnabled:YES];
    }
    
    [[self tableView] reloadData];
}

- (void)share:(id)sender
{
    PropertyListEmailerViewController *listEmailer = [[PropertyListEmailerViewController alloc] init];
    [listEmailer setMailComposeDelegate:self];
    
    PropertySummary *property = [[self details] summary];
    NSArray *properties = [[NSArray alloc] initWithObjects:property, nil];
    [listEmailer setProperties:properties];
    [properties release];
    
    [self presentModalViewController:listEmailer animated:YES];
    [listEmailer release];
}

- (void)addToFavorites:(id)sender
{
    PropertySummary *property = [[self details] summary];
    if (![PropertyFavoritesViewController addCopyOfProperty:property])
    {
        DebugLog(@"Already in favorites.");
    }
    else
    {
        [[self addToFavoritesButton] setEnabled:NO];
        DebugLog(@"Added to favorites.");
    }
}

- (BOOL)hasDisclosureIndicator:(NSString *)key
{
    #ifdef HOME_FINDER
        return [key isEqual:kDetailsImages] || [key isEqual:kDetailsLink] || [key isEqual:kDetailsEmail] || [key isEqual:kDetailsLocation] || [key isEqual:kDetailsPrice] || [key isEqual:kDetailsTruliaCopyright] || [key isEqual:kDetailsProvidedByTrulia];
    #else
        return [key isEqual:kDetailsImages] || [key isEqual:kDetailsLink] || [key isEqual:kDetailsEmail] || [key isEqual:kDetailsLocation];
    #endif
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
#ifdef HOME_FINDER
        if ([[[self details] source] isEqual:@"Trulia"])
        {
            [contactSection setObject:@"copyright placeholder" forKey:kDetailsTruliaCopyright];
            [contactSection setObject:@"image placeholder" forKey:kDetailsProvidedByTrulia];
        }
        else
        {

            [contactSection setObject:[[self details] source] forKey:kDetailsSource];
        }
#else
        [contactSection setObject:[[self details] source] forKey:kDetailsSource];
#endif
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];

    // The TTPhotoViewer changes the nav bar and status bar style to translucent back, so it needs to be changed back
    [[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sets title to: "1 of 50"
    NSInteger propertyCount = [[self propertyDataSource] numberOfPropertiesInView:[self tableView]];
    NSString *title = [[NSString alloc] initWithFormat:@"%d of %d", [self propertyIndex] + 1, propertyCount];
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
    if ([PropertyFavoritesViewController isPropertyAFavorite:[[self details] summary]])
    {
        [[self addToFavoritesButton] setEnabled:NO];
    }
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
#ifdef HOME_FINDER
    else if ([key isEqual:kDetailsTruliaCopyright])
    {
        return [TruliaCopyrightCell height];
    }
    else if ([key isEqual:kDetailsProvidedByTrulia])
    {
        return [ProvidedByTruliaCell height];
    }
#endif
    
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
    
// Cells specific to Home Finder
#ifdef HOME_FINDER
    //Trulia copyright cell
    if ([key isEqual:kDetailsTruliaCopyright])
    {
        static NSString *kTruliaCopyrightCell = @"TRULIA_COPYRIGHT_CELL_ID";
        
        [self setTruliaCopyrightCell:(TruliaCopyrightCell *)[[self tableView] dequeueReusableCellWithIdentifier:kTruliaCopyrightCell]];
        if ([self truliaCopyrightCell] == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TruliaCopyrightCell" owner:self options:nil];
        }
        
        return [self truliaCopyrightCell];
    }
    
    //Provided by Trulia cell
    if ([key isEqual:kDetailsProvidedByTrulia])
    {
        static NSString *kProvidedByTruliaCell = @"PROVIDED_BY_TRULIA_CELL_ID";
        
        [self setProvidedByTruliaCell:(ProvidedByTruliaCell *)[[self tableView] dequeueReusableCellWithIdentifier:kProvidedByTruliaCell]];
        if ([self providedByTruliaCell] == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ProvidedByTruliaCell" owner:self options:nil];
        }
        
        return [self providedByTruliaCell];
    }
#endif
    
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
//        PropertyMapViewController *mapController = [[PropertyMapViewController alloc] initWithNibName:@"PropertyMapView" bundle:nil];
//        [mapController setSummary:[[self details] summary]];
//        
//        [[self navigationController] pushViewController:mapController animated:YES];
//        [mapController release];
    }
    
    if ([key isEqual:kDetailsImages])
    {
        NSMutableArray *urls = [[NSMutableArray alloc] init];
        for (PropertyImage *image in [[self details] images])
        {
            NSURL *url = [[NSURL alloc] initWithString:[image url]];
            [urls addObject:url];
            [url release];
        }
        
        ImagesViewController *imageViewController = [[ImagesViewController alloc] initWithUrls:urls];
        [urls release];
        
        [[self navigationController] pushViewController:imageViewController animated:YES];
        [imageViewController release];
    }
    
    if ([key isEqual:kDetailsLink])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
        
        NSURL *url = [[NSURL alloc] initWithString:detail];
        [webViewController setUrl:url];
        [url release];

        [[self navigationController] pushViewController:webViewController animated:YES];
        [webViewController release];
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

#ifdef HOME_FINDER    
    //Home Finder populates Mortgage Criteria page with property data
    if ([key isEqual:kDetailsPrice])
    {
        MortgageCriteriaViewController *criteriaViewController = [[MortgageCriteriaViewController alloc] initWithNibName:@"MortgageCriteriaView" bundle:nil];
        [criteriaViewController setProperty:[[self details] summary]];
        [[self navigationController] pushViewController:criteriaViewController animated:YES];
        [criteriaViewController release];                            
    }

    //See http://developer.trulia.com/page/read/Tou for Trulia Terms of Use
    //Trulia copyright loads Terms of Use page
    if ([key isEqual:kDetailsTruliaCopyright])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
        
        NSURL *url = [[NSURL alloc] initWithString:kDetailsTruliaCopyrightUrl];
        [webViewController setUrl:url];
        [url release];
        
        [[self navigationController] pushViewController:webViewController animated:YES];
        [webViewController release];
    }

    //Provided by Trulia goes to www.trulia.com
    if ([key isEqual:kDetailsProvidedByTrulia])
    {
        WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
        
        NSURL *url = [[NSURL alloc] initWithString:kDetailsProvidedByTruliaUrl];
        [webViewController setUrl:url];
        [url release];
        
        [[self navigationController] pushViewController:webViewController animated:YES];
        [webViewController release];        
    }
#endif

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
