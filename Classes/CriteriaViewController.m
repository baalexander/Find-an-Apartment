#import "CriteriaViewController.h"

#import "InputRangeCell.h"
#import "InputSimpleCell.h"


@interface CriteriaViewController ()

@end


@implementation CriteriaViewController

@synthesize currentTextField = currentTextField_;
@synthesize rowIds = rowIds_;
@synthesize selectedRow = selectedRow_;
@synthesize selectedIndexPath = selectedIndexPath_;
@synthesize inputRangeCell = inputRangeCell_;
@synthesize inputSimpleCell = inputSimpleCell_;


#pragma mark -
#pragma mark CriteriaViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [currentTextField_ release];
    [rowIds_ release];
    [inputRangeCell_ release];
    [inputSimpleCell_ release];
    [selectedIndexPath_ release];
    
    [super dealloc];
}

- (InputRangeCell *)inputRangeCellWithMin:(NSNumber *)min withMax:(NSNumber *)max
{
    static NSString *kInputRangeCellId = @"INPUT_RANGE_CELL_ID";
    
    [self setInputRangeCell:(InputRangeCell *)[[self tableView] dequeueReusableCellWithIdentifier:kInputRangeCellId]];
    if ([self inputRangeCell] == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"InputRangeCell" owner:self options:nil];
    }
    
    [[[self inputRangeCell] minRange] setText:[min stringValue]];
    [[[self inputRangeCell] maxRange] setText:[max stringValue]];
    
    return [self inputRangeCell];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //If selecting a choices view controller like Sort By choices, then need to reload any changes it may have made on the Criteria
    [[self tableView] reloadData];
    
    // Reloading the tableView's data causes the row to be deselected; re-select a previously selected cell so it can be deselected
    [[self tableView] selectRowAtIndexPath:[self selectedIndexPath] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

// Deselect the previously selected row
- (void)viewDidAppear:(BOOL)animated
{
    [[self tableView] deselectRowAtIndexPath:[self selectedIndexPath] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Deselect all rows
    [self setSelectedRow:-1];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self rowIds] count];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setCurrentTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self currentTextField] resignFirstResponder];
    
    return YES;
}

@end
