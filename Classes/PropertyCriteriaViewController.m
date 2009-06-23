#import "PropertyCriteriaViewController.h"

#import "PropertyHistoryViewController.h"
#import "PropertyCriteriaConstants.h"
#import "InputRangeCell.h"
#import "InputSimpleCell.h"
#import "PropertyUrlConstructor.h"
#import "PropertyListViewController.h"
#import "PropertySortChoicesViewController.h"
#import "StringFormatter.h"


@interface PropertyCriteriaViewController ()

@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) PropertyCriteria *criteria;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL isEditingRow;
@property (nonatomic, retain) NSMutableArray *rowIds;

- (InputRangeCell *)inputRangeCellWithMin:(NSNumber *)min withMax:(NSNumber *)max;
- (InputSimpleCell *)inputSimpleCellWithText:(NSString *)text;
- (UITableViewCell *)simpleCellWithText:(NSString *)text withDetail:(NSString *)detailText;
- (UITableViewCell *)buttonCellWithText:(NSString *)text;

@end


@implementation PropertyCriteriaViewController

@synthesize mainObjectContext = mainObjectContext_;
@synthesize state = state_;
@synthesize city = city_;
@synthesize postalCode = postalCode_;
@synthesize coordinates = coordinates_;
@synthesize criteria = criteria_;
@synthesize currentTextField = currentTextField_;
@synthesize rowIds = rowIds_;
@synthesize selectedRow = selectedRow_;
@synthesize isEditingRow = isEditingRow_;
@synthesize inputRangeCell = inputRangeCell_;
@synthesize inputSimpleCell = inputSimpleCell_;


#pragma mark -
#pragma mark PropertyCriteriaViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {

    }
    
    return self;
}

- (void)dealloc
{
    [mainObjectContext_ release];
    
    [state_ release];
    [city_ release];
    [postalCode_ release];
    [coordinates_ release];
    [criteria_ release];
    
    [currentTextField_ release];
    [rowIds_ release];
    
    [inputRangeCell_ release];
    [inputSimpleCell_ release];
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Creates Criteria object to hold all the user input
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyCriteria" inManagedObjectContext:[self mainObjectContext]];
    PropertyCriteria *criteria = [[PropertyCriteria alloc] initWithEntity:entity insertIntoManagedObjectContext:[self mainObjectContext]];
    [self setCriteria:criteria];
    [criteria release];
    //Fills criteria in with passed in information
    [[self criteria] setState:[[self state] name]];    
    [[self criteria] setCity:[[self city] value]];
    [[self criteria] setPostalCode:[[self postalCode] value]];
    [[self criteria] setCoordinates:[self coordinates]];
    
    //Sets title to location
    NSString *title;
    if ([[self criteria] postalCode] != nil && [[[self criteria] postalCode] length] > 0)
    {
        title = [[self criteria] postalCode];
    }
    else if ([[self criteria] city] != nil 
             && [[[self criteria] city] length] > 0 
             && [[self criteria] state] != nil
             && [[[self criteria] state] length] > 0)
    {
        title = [NSString stringWithFormat:@"%@, %@", [[self criteria] city], [[self criteria] state]];
    }
    else
    {
        title = @"Criteria";
    }
    [self setTitle:title];
    
    //Row Ids outlines the order of the rows in the table. The integer value of each constant does NOT impact the order.
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kCriteriaStreet, kCriteriaKeywords, kCriteriaPrice, kCriteriaSquareFeet, kCriteriaBedrooms, kCriteriaBathrooms, kCriteriaSortBy, kCriteriaSearch, nil];
    [self setRowIds:rowIds];
    [rowIds release];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    //If this cell is the selected cell, then returns a cell for inputting
    //The reason for the > 0 and NSInteger cast is because comparing signed to unsigned integer
    BOOL isSelectedRow = [self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row];
    
    //When selected, these cells display a simple input cell
    if ([rowId isEqual:kCriteriaStreet])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:[[self criteria] street]];
        }
        else
        {
            NSString *detailText = @"(optional)";
            if ([[self criteria] street] != nil && [[[self criteria] street] length] > 0)
            {
                detailText = [[self criteria] street];
            }
            
            return [self simpleCellWithText:@"street" withDetail:detailText];
        }
    }
    else if ([rowId isEqual:kCriteriaKeywords])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:[[self criteria] keywords]];
        }
        else
        {
            NSString *detailText = @"(optional)";
            if ([[self criteria] keywords] != nil && [[[self criteria] keywords] length] > 0)
            {
                detailText = [[self criteria] keywords];
            }
            
            return [self simpleCellWithText:@"keywords" withDetail:detailText];
        }
    }        
    //When selected, these cells display an input range cell
    else if ([rowId isEqual:kCriteriaPrice])
    {
        if (isSelectedRow)
        {
            return [self inputRangeCellWithMin:[[self criteria] minPrice] withMax:[[self criteria] maxPrice]];
        }
        else
        {            
            return [self simpleCellWithText:@"price" withDetail:[StringFormatter formatCurrencyRangeWithMin:[[self criteria] minPrice] withMax:[[self criteria] maxPrice]]];
        }
    }
    else if ([rowId isEqual:kCriteriaSquareFeet])
    {
        if (isSelectedRow)
        {
            return [self inputRangeCellWithMin:[[self criteria] minSquareFeet] withMax:[[self criteria] maxSquareFeet]];
        }
        else
        {            
            return [self simpleCellWithText:@"sq feet" withDetail:[StringFormatter formatRangeWithMin:[[self criteria] minSquareFeet] withMax:[[self criteria] maxSquareFeet] withUnits:@"sqft"]];
        }
    }
    else if ([rowId isEqual:kCriteriaBedrooms])
    {
        if (isSelectedRow)
        {
            return [self inputRangeCellWithMin:[[self criteria] minBedrooms] withMax:[[self criteria] maxBedrooms]];
        }
        else
        {            
            return [self simpleCellWithText:@"bedrooms" withDetail:[StringFormatter formatRangeWithMin:[[self criteria] minBedrooms] withMax:[[self criteria] maxBedrooms] withUnits:@"rooms"]];
        }
    }
    else if ([rowId isEqual:kCriteriaBathrooms])
    {
        if (isSelectedRow)
        {
            return [self inputRangeCellWithMin:[[self criteria] minBathrooms] withMax:[[self criteria] maxBathrooms]];
        }
        else
        {            
            return [self simpleCellWithText:@"bathrooms" withDetail:[StringFormatter formatRangeWithMin:[[self criteria] minBathrooms] withMax:[[self criteria] maxBathrooms] withUnits:@"baths"]];
        }
    }
    //When selected, these cells bring up a choices view controller.
    else if ([rowId isEqual:kCriteriaSortBy])
    {
        UITableViewCell *cell = [self simpleCellWithText:@"sort by" withDetail:[[self criteria] sortBy]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        return cell;
    }
    else if ([rowId isEqual:kCriteriaSearch])
    {
        return [self buttonCellWithText:@"Search"];
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
    if ([rowId isEqual:kCriteriaSearch])
    {
        PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
        
        //Sets History
        PropertyHistory *history = [PropertyHistoryViewController historyWithCopyOfCriteria:[self criteria]];
        [history setTitle:[self title]];
        [listViewController setHistory:history];
        
        //Turns Criteria into URL then parses
        PropertyUrlConstructor *urlConstructor = [[PropertyUrlConstructor alloc] init];
        NSURL *url = [urlConstructor urlFromCriteria:[self criteria]];
        [urlConstructor release];
        [listViewController parse:url];

        [[self navigationController] pushViewController:listViewController animated:YES];
        [listViewController release];
    }
    //Selected sort by, brings up list of sort choices
    else if ([rowId isEqual:kCriteriaSortBy]) 
    {
        PropertySortChoicesViewController *choicesViewController = [[PropertySortChoicesViewController alloc] initWithNibName:@"PropertySortChoicesView" bundle:nil];
        [choicesViewController setCriteria:[self criteria]];
        [[self navigationController] pushViewController:choicesViewController animated:YES];
        [choicesViewController release];
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
    NSString *rowId = [[self rowIds] objectAtIndex:[self selectedRow]];
    NSString *text = [textField text];
    
    //Sets the correct Criteria attribute to the inputted valu
    if ([rowId isEqual:kCriteriaStreet])
    {
        [[self criteria] setStreet:text];
    }
    else if ([rowId isEqual:kCriteriaKeywords])
    {
        [[self criteria] setKeywords:text];
    }
    else if ([rowId isEqual:kCriteriaPrice])
    {
        //Why not create this Number earlier for all to share? Because could be initializing from an int or a float (like Bathrooms).
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        //Tag values set in the Xib are used to distinguish between the min and max input text fields
        if ([textField tag] == kCriteriaMinTag)
        {
            [[self criteria] setMinPrice:number];
        }
        else if ([textField tag] == kCriteriaMaxTag)
        {
            [[self criteria] setMaxPrice:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kCriteriaSquareFeet])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        if ([textField tag] == kCriteriaMinTag)
        {
            [[self criteria] setMinSquareFeet:number];
        }
        else if ([textField tag] == kCriteriaMaxTag)
        {
            [[self criteria] setMaxSquareFeet:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kCriteriaBedrooms])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        if ([textField tag] == kCriteriaMinTag)
        {
            [[self criteria] setMinBedrooms:number];
        }
        else if ([textField tag] == kCriteriaMaxTag)
        {
            [[self criteria] setMaxBedrooms:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kCriteriaBathrooms])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        if ([textField tag] == kCriteriaMinTag)
        {
            [[self criteria] setMinBathrooms:number];
        }
        else if ([textField tag] == kCriteriaMaxTag)
        {
            [[self criteria] setMaxBathrooms:number];
        }
        [number release];
    }
    
    [self setCurrentTextField:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self currentTextField] resignFirstResponder];
    
    return YES;
}

@end
