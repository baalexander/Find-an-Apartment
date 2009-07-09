#import "MortgageCriteriaViewController.h"

#import "MortgageCriteriaConstants.h"


@interface MortgageCriteriaViewController ()
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, retain) NSArray *rowIds;
@end


@implementation MortgageCriteriaViewController

@synthesize currentTextField = currentTextField_;
@synthesize rowIds = rowIds_;
@synthesize selectedRow = selectedRow_;


#pragma mark -
#pragma mark MortgageCriteriaViewController

- (void)dealloc
{
    [currentTextField_ release];
    [rowIds_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Row Ids outlines the order of the rows in the table. The integer value of each constant does NOT impact the order.
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kMortgageCriteriaPostalCode, kMortgageCriteriaPrice, kMortgageCriteriaPercentDown, kMortgageCriteriaCashDown, kMortgageCriteriaLoanAmount, kMortgageCriteriaLoanTerm, kMortgageCriteriaLoanRate, kMortgageCriteriaCalculate, nil];
    [self setRowIds:rowIds];
    [rowIds release];
    
    //Deselect all rows
    [self setSelectedRow:-1];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self rowIds] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    //If this cell is the selected cell, then returns a cell for inputting
    //The reason for the > 0 and NSInteger cast is because comparing signed to unsigned integer
    //BOOL isSelectedRow = [self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row];
    
    static NSString *kSimpleCellId = @"SIMPLE_CELL_ID";
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:kSimpleCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kSimpleCellId] autorelease];
    }
    //Prevents selection background popping up quickly when pressed. Sometimes it's too quick to see, but this prevents it from showing up at all.
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //Since reusing cells, need to reset this to None
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if ([rowId isEqual:kMortgageCriteriaPostalCode])
    {
        [[cell textLabel] setText:@"zip code"];
    }
    else if ([rowId isEqual:kMortgageCriteriaPrice])
    {
        [[cell textLabel] setText:@"price"];
    }
    else if ([rowId isEqual:kMortgageCriteriaPercentDown])
    {
        [[cell textLabel] setText:@"% down"];
    }
    else if ([rowId isEqual:kMortgageCriteriaCashDown])
    {
        [[cell textLabel] setText:@"cash down"];
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanAmount])
    {
        [[cell textLabel] setText:@"loan amt"];
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanTerm])
    {
        [[cell textLabel] setText:@"loan term"];
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanRate])
    {
        [[cell textLabel] setText:@"loan rate"];
    }
    else if ([rowId isEqual:kMortgageCriteriaCalculate])
    {
        [[cell textLabel] setText:@"calculate"];
    }
    
    return cell;
}


@end
