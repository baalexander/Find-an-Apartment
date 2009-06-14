#import "PropertyCriteriaViewController.h"

#import "PropertyCriteriaConstants.h"
#import "InputRangeCell.h"
#import "InputSimpleCell.h"
#import "PropertyUrlConstructor.h"
#import "PropertyListViewController.h"
#import "PropertySortChoicesViewController.h"


@interface PropertyCriteriaViewController ()

@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) PropertyCriteria *criteria;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL isEditingRow;
@property (nonatomic, retain) NSMutableArray *rowIds;

- (NSString *)formatRangeWithMin:(NSString *)min withMax:(NSString *)max withSymbol:(NSString *)symbol withUnits:(NSString *)units;
- (BOOL)inputIsValid;

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

//Returns range in the following formats depending on what parameters are sent:
//  min - max units
//  0 - max units
//  min+ units
- (NSString *)formatRangeWithMin:(NSString *)min withMax:(NSString *)max withSymbol:(NSString *)symbol withUnits:(NSString *)units
{
    //Placeholders
    if (symbol == nil)
    {
        symbol = @"";
    }
    if (units == nil)
    {
        units = @"";
    }
    else
    {
        units = [NSString stringWithFormat:@" %@", units];
    }
    
    //Formats min and max numbers
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *minNumber = [[NSNumber alloc] initWithInteger:[min integerValue]];
    NSString *formattedMin = [formatter stringFromNumber:minNumber];
    [minNumber release];
    NSNumber *maxNumber = [[NSNumber alloc] initWithInteger:[max integerValue]];
    NSString *formattedMax = [formatter stringFromNumber:maxNumber];
    [maxNumber release];
    
    [formatter release];
    
    //Returns range based on which values were provided
    if ([formattedMin isEqual:@"0"] && [formattedMax isEqual:@"0"])
    {
        return [NSString stringWithFormat:@"%@0+%@", symbol, units];
    }
    else if ([formattedMin isEqual:@"0"])
    {
        return [NSString stringWithFormat:@"%@0 - %@%@%@", symbol, symbol, formattedMax, units];
    }
    else if ([formattedMax isEqual:@"0"])
    {
        return [NSString stringWithFormat:@"%@%@+%@", symbol, formattedMin, units];
    }
    else
    {
        return [NSString stringWithFormat:@"%@%@ - %@%@%@", symbol, formattedMin, symbol, formattedMax, units];
    }
}

//Returns YES if all input is valid. Displays error UIAlertView and returns NO if invalid.
- (BOOL)inputIsValid
{	
	NSString *errorMessage = @"";

	//Validates price
    NSString *minPrice = [[self criteria] minPrice];
    NSString *maxPrice = [[self criteria] maxPrice];
    if ([minPrice length] > 0 && [minPrice integerValue] == 0)
    {
        errorMessage = @"Min price must be a valid number.";
    }
    else if ([maxPrice length] > 0 && [maxPrice integerValue] == 0)
    {
        errorMessage = @"Max price must be a valid number.";
    }
	//Validates square feet
	if ([errorMessage length] == 0)
	{
        NSString *minSquareFeet = [[self criteria] minSquareFeet];
        NSString *maxSquareFeet = [[self criteria] maxSquareFeet];
        if ([minSquareFeet length] > 0 && [minSquareFeet integerValue] == 0)
        {
            errorMessage = @"Min square feet must be a valid number.";
        }
        else if ([maxSquareFeet length] > 0 && [maxSquareFeet integerValue] == 0)
        {
            errorMessage = @"Max square feet must be a valid number.";
        }
	}
	//Validates bedrooms
	if ([errorMessage length] == 0)
	{
        NSString *minBedrooms = [[self criteria] minBedrooms];
        NSString *maxBedrooms = [[self criteria] maxBedrooms];
        if ([minBedrooms length] > 0 && [minBedrooms integerValue] == 0)
        {
            errorMessage = @"Min bedrooms must be a valid number.";
        }
        else if ([maxBedrooms length] > 0 && [maxBedrooms integerValue] == 0)
        {
            errorMessage = @"Max bedrooms must be a valid number.";
        }
	}
	//Validates bathrooms
	if ([errorMessage length] == 0)
	{
        NSString *minBathrooms = [[self criteria] minBathrooms];
        NSString *maxBathrooms = [[self criteria] maxBathrooms];
        if ([minBathrooms length] > 0 && [minBathrooms integerValue] == 0)
        {
            errorMessage = @"Min bathrooms must be a valid number.";
        }
        else if ([maxBathrooms length] > 0 && [maxBathrooms integerValue] == 0)
        {
            errorMessage = @"Max bathrooms must be a valid number.";
        }
	}
	
	if ([errorMessage length] > 0)
	{
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Invalid input" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[errorAlert show];
		[errorAlert release];
		
		return NO;
	}
	
	return YES;
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
    [[self criteria] setCity:[[self city] name]];
    [[self criteria] setPostalCode:[[self postalCode] name]];
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
    
    //Row Ids outlines the order of the rows in the table
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kSource, kLocation, kPrice, kSquareFeet, kBedrooms, kBathrooms, kSortBy, kSearch, nil];
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

static NSString *kInputRangeCellId = @"INPUT_RANGE_CELL_ID";
static NSString *kInputSimpleCellId = @"INPUT_SIMPLE_CELL_ID";
static NSString *kSimpleCellId = @"SIMPLE_CELL_ID";
static NSString *kButtonCellId = @"BUTTON_CELL_ID";


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self rowIds] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    
    //Returns an input cell
    //The reason for the > 0 and NSInteger cast is because comparing signed to unsigned integer
    if ([self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row])
    {
        //Returns input range cell
        if ([rowId isEqual:kPrice] || [rowId isEqual:kSquareFeet] || [rowId isEqual:kBedrooms] || [rowId isEqual:kBathrooms])
        {
            [self setInputRangeCell:(InputRangeCell *)[tableView dequeueReusableCellWithIdentifier:kInputRangeCellId]];
            if ([self inputRangeCell] == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"InputRangeCell" owner:self options:nil];
            }
            if ([rowId isEqual:kPrice])
            {
                [[[self inputRangeCell] minRange] setText:[[self criteria] minPrice]];
                [[[self inputRangeCell] maxRange] setText:[[self criteria] maxPrice]];
            }
            else if ([rowId isEqual:kSquareFeet])
            {
                [[[self inputRangeCell] minRange] setText:[[self criteria] minSquareFeet]];
                [[[self inputRangeCell] maxRange] setText:[[self criteria] maxSquareFeet]];
            }
            else if ([rowId isEqual:kBedrooms])
            {
                [[[self inputRangeCell] minRange] setText:[[self criteria] minBedrooms]];
                [[[self inputRangeCell] maxRange] setText:[[self criteria] maxBedrooms]];
            }
            else if ([rowId isEqual:kBathrooms])
            {
                [[[self inputRangeCell] minRange] setText:[[self criteria] minBathrooms]];
                [[[self inputRangeCell] maxRange] setText:[[self criteria] maxBathrooms]];
            }
            
            return [self inputRangeCell];            
        }
        //Returns input simple cell
        else
        {
            [self setInputSimpleCell:(InputSimpleCell *)[tableView dequeueReusableCellWithIdentifier:kInputSimpleCellId]];
            if ([self inputSimpleCell] == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"InputSimpleCell" owner:self options:nil];
            }
            if ([rowId isEqual:kLocation])
            {
                [[[self inputSimpleCell] input] setText:[[self criteria] street]];
            }
            
            return [self inputSimpleCell]; 
        }
    }
    //Returns a button cell
    else if ([rowId isEqual:kSearch])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kButtonCellId];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kButtonCellId] autorelease];
        }
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [[cell textLabel] setText:@"Search"];
        [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
        
        return cell;        
    }
    //Returns a simple cell
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleCellId];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kSimpleCellId] autorelease];
        }
        
        if ([rowId isEqual:kSource])
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            [[cell textLabel] setText:@"source"];
            [[cell detailTextLabel] setText:[[self criteria] searchSource]];
        }
        else if ([rowId isEqual:kLocation])
        {
            [[cell textLabel] setText:@"street"];
            if ([[self criteria] street] == nil || [[[self criteria] street] length] == 0)
            {
                [[cell detailTextLabel] setText:@"(optional)"];
            }
            else
            {
                [[cell detailTextLabel] setText:[[self criteria] street]];
            }
        }
        else if ([rowId isEqual:kPrice])
        {
            [[cell textLabel] setText:@"price"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minPrice] withMax:[[self criteria] maxPrice] withSymbol:@"$" withUnits:nil]];
        }
        else if ([rowId isEqual:kSquareFeet])
        {
            [[cell textLabel] setText:@"sq feet"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minSquareFeet] withMax:[[self criteria] maxSquareFeet] withSymbol:nil withUnits:@"sqft"]];
        }
        else if ([rowId isEqual:kBedrooms])
        {
            [[cell textLabel] setText:@"bedrooms"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minBedrooms] withMax:[[self criteria] maxBedrooms] withSymbol:nil withUnits:@"rooms"]];
        }
        else if ([rowId isEqual:kBathrooms])
        {
            [[cell textLabel] setText:@"bathrooms"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minBathrooms] withMax:[[self criteria] maxBathrooms] withSymbol:nil withUnits:@"baths"]];
        }
        else if ([rowId isEqual:kSortBy])
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            [[cell textLabel] setText:@"sort by"];
            [[cell detailTextLabel] setText:[[self criteria] sortBy]];            
        }
        
        return cell;
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    
    //Selected the search button, begins searching
    if ([rowId isEqual:kSearch])
    {
        if (![self inputIsValid])
        {
            return;
        }
        
        //Gets URL to download
        PropertyUrlConstructor *urlConstructor = [[PropertyUrlConstructor alloc] init];
        NSURL *url = [urlConstructor urlFromCriteria:[self criteria]];
        [urlConstructor release];
        
        //Create History object with this Criteria
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:[self mainObjectContext]];
        PropertyHistory *history = [[PropertyHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:[self mainObjectContext]];
        [history setCriteria:[self criteria]];
        
        PropertyListViewController *listViewController = [[PropertyListViewController alloc] initWithNibName:@"PropertyListView" bundle:nil];
        [listViewController setHistory:history];
        [history release];
        //(TODO: Re-evaluate this claim after History fetching when nil fixed, like when going from map to list)Must call parse BEFORE pushing to view. Otherwise, an unecessary perform fetch is done in the view controller.
        [listViewController parse:url];
        [[self navigationController] pushViewController:listViewController animated:YES];
        [listViewController release];
    }
    //Selected sort by, brings up list of sort choices
    else if ([rowId isEqual:kSortBy]) 
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
    
    //Sets the correct Criteria attribute to the inputted value
    //Tag values set in the Xib are used to distinguish between the min and max input text fields
    if ([rowId isEqual:kLocation])
    {
        [[self criteria] setStreet:text];
    }
    else if ([rowId isEqual:kPrice])
    {
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinPrice:text];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxPrice:text];
        }
    }
    else if ([rowId isEqual:kSquareFeet])
    {
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinSquareFeet:text];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxSquareFeet:text];
        }
    }
    else if ([rowId isEqual:kBedrooms])
    {
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinBedrooms:text];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxBedrooms:text];
        }
    }
    else if ([rowId isEqual:kBathrooms])
    {
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinBathrooms:text];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxBathrooms:text];
        }
    }
    
    [self setCurrentTextField:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self currentTextField] resignFirstResponder];
    
	return YES;
}

@end
