#import "PropertyListViewController.h"

#import "StringFormatter.h"


@interface PropertyListViewController ()
@end


@implementation PropertyListViewController

@synthesize tableView = tableView_;
@synthesize summaryCell = summaryCell_;
@synthesize propertyDelegate = propertyDelegate_;
@synthesize propertyDataSource = propertyDataSource_;


#pragma mark -
#pragma mark PropertyListViewController

- (void)dealloc
{
    [tableView_ release];
    [summaryCell_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad]; 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedRowIndexPath = [[self tableView] indexPathForSelectedRow];
    [[self tableView] deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

static NSString *kSummaryCellId = @"SUMMARY_CELL_ID";


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self propertyDataSource] numberOfPropertiesInView:[self tableView]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSummaryCell:(SummaryCell *)[tableView dequeueReusableCellWithIdentifier:kSummaryCellId]];
    if ([self summaryCell] == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SummaryCell" owner:self options:nil];
    }

    // Configures cell with Summary data
    PropertySummary *property = [[self propertyDataSource] view:[self tableView]
                                               propertyAtIndex:[indexPath row]];
    [[[self summaryCell] title] setText:[property title]];
    [[[self summaryCell] subtitle] setText:[property subtitle]];
    [[[self summaryCell] summary] setText:[property summary]];
    
    NSString *price = [StringFormatter formatCurrency:[property price]];
    [[[self summaryCell] price] setText:price];
    
    return [self summaryCell];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([[self propertyDataSource] respondsToSelector:@selector(view:deletePropertyAtIndex:)])
        {
            [[self propertyDataSource] view:[self tableView] deletePropertyAtIndex:[indexPath row]];
        }
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self propertyDelegate] view:[self tableView] didSelectPropertyAtIndex:[indexPath row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

@end
