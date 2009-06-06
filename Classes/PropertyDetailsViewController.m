#import "PropertyDetailsViewController.h"


@interface PropertyDetailsViewController ()
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@property (nonatomic, retain) NSMutableArray *sectionDetails;
@end

@implementation PropertyDetailsViewController

@synthesize details = details_;
@synthesize sectionTitles = sectionTitles_;
@synthesize sectionDetails = sectionDetails_;


#pragma mark -
#pragma mark PropertyDetailsViewController

- (void)dealloc
{
    [details_ release];
    [sectionTitles_ release];
    [sectionDetails_ release];
    
    [super dealloc];
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
    NSMutableDictionary *locationSection = [NSMutableDictionary dictionary];
    if ([[self details] location] != nil)
    {
        [locationSection setObject:[[self details] location] forKey:@"location"];
    }
    if ([locationSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Location"];
        [[self sectionDetails] addObject:locationSection];
    }
    
    //Finance section
    NSMutableDictionary *financeSection = [NSMutableDictionary dictionary];
    if ([[self details] price] != nil)
    {
        [financeSection setObject:[[self details] price] forKey:@"price"];
    }
    if ([financeSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Finance"];
        [[self sectionDetails] addObject:financeSection];
    }
    
    //Details section
    NSMutableDictionary *detailsSection = [NSMutableDictionary dictionary];
    if ([[self details] squareFeet] != nil)
    {
        [detailsSection setObject:[[self details] squareFeet] forKey:@"sq feet"];
    }
    if ([[self details] bedrooms] != nil)
    {
        [detailsSection setObject:[[self details] bedrooms] forKey:@"bedrooms"];
    }
    if ([[self details] bathrooms] != nil)
    {
        [detailsSection setObject:[[self details] bathrooms] forKey:@"bathrooms"];
    }    
    if ([[self details] year] != nil)
    {
        [detailsSection setObject:[[self details] year] forKey:@"year"];
    }
    if ([[self details] lotSize] != nil)
    {
        [detailsSection setObject:[[self details] lotSize] forKey:@"lot size"];
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
    
    //Contact section
    NSMutableDictionary *contactSection = [NSMutableDictionary dictionary];
    if ([[self details] source] != nil)
    {
        [contactSection setObject:[[self details] source] forKey:@"source"];
    }
    if ([[self details] email] != nil)
    {
        //TODO Validate email before adding?
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
    
    //TODO Images section

    //Description section
    NSMutableDictionary *descriptionSection = [NSMutableDictionary dictionary];
    if ([[self details] details] != nil)
    {
        [descriptionSection setObject:[[self details] details] forKey:@"description"];
    }
    if ([descriptionSection count] > 0)
    {
        [[self sectionTitles] addObject:@"Description"];
        [[self sectionDetails] addObject:descriptionSection];
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    NSDictionary *details = [[self sectionDetails] objectAtIndex:[indexPath section]];
    NSArray *keys = [details allKeys];
    NSString *key = [keys objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kSimpleCellId] autorelease];
    }

    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:[details objectForKey:key]];
    
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}    



@end
