#import "MortgageCriteriaViewController.h"

#import "MortgageCriteriaConstants.h"
#import "InputRangeCell.h"
#import "InputSimpleCell.h"


@interface MortgageCriteriaViewController ()
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, retain) NSArray *rowIds;
@end


@implementation MortgageCriteriaViewController

@synthesize currentTextField = currentTextField_;
@synthesize rowIds = rowIds_;
@synthesize selectedRow = selectedRow_;
@synthesize criteria = criteria_;
@synthesize inputRangeCell = inputRangeCell_;
@synthesize inputSimpleCell = inputSimpleCell_;


#pragma mark -
#pragma mark MortgageCriteriaViewController

- (void)dealloc
{
    [currentTextField_ release];
    [rowIds_ release];
    [inputRangeCell_ release];
    [inputSimpleCell_ release];
    
    [super dealloc];
}

- (InputSimpleCell *)inputSimpleCellWithText:(NSString *)text
{
    static NSString *kInputSimpleCellId = @"INPUT_SIMPLE_CELL_ID";
    
    [self setInputSimpleCell:(InputSimpleCell *)[[self tableView] dequeueReusableCellWithIdentifier:kInputSimpleCellId]];
    if ([self inputSimpleCell] == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"InputSimpleCell" owner:self options:nil];
    }
    
    [[[self inputSimpleCell] input] setText:text];
    
    return [self inputSimpleCell];
}

- (UITableViewCell *)simpleCellWithText:(NSString *)text withDetail:(NSString *)detailText
{
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
    
    [[cell textLabel] setText:text];
    [[cell detailTextLabel] setText:detailText];
    
    return cell;
}

- (UITableViewCell *)buttonCellWithText:(NSString *)text
{
    static NSString *kButtonCellId = @"BUTTON_CELL_ID";
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:kButtonCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonCellId] autorelease];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setText:text];
    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
    
    return cell;
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
    BOOL isSelectedRow = [self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row];
    
    //When selected, these cells display a simple input cell
    if ([rowId isEqual:kMortgageCriteriaPostalCode])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"zip code" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaPrice])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"price" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaPercentDown])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"% down" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaCashDown])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"cash down" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanAmount])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"loan amt" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanTerm])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"loan term" withDetail:@""];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanRate])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:@""];
        }
        else
        {
            return [self simpleCellWithText:@"loan rate" withDetail:@""];
        }
    }
    //Button cell
    else if ([rowId isEqual:kMortgageCriteriaCalculate])
    {
        return [self buttonCellWithText:@"calculate"];
    }
    
    return nil;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If currently editing an input field, returns that text field.
    //This fixes all sorts of quacky issues when the user does not manually press Return
    if ([self currentTextField] != nil)
    {
        [self textFieldShouldReturn:[self currentTextField]];
    }
    
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    
    //Selected the search button, begins searching
    if ([rowId isEqual:kMortgageCriteriaCalculate])
    {
        
    }
    //Puts the cell in edit mode or view mode if already in edit mode
    else
    {
        //If pressing a row that's already in edit mode (was selected last), then resets to unedit mode
        if ([self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row])
        {
            [self setSelectedRow:-1];
        }
        //Sets row to be edited
        else
        {
            [self setSelectedRow:[indexPath row]];
        }
        
        [tableView reloadData];
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setCurrentTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setCurrentTextField:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self currentTextField] resignFirstResponder];
    
    return YES;
}

@end
