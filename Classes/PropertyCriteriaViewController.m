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

- (NSString *)formatRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units;
- (NSString *)formatCurrencyRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max;

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
- (NSString *)formatRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units
{
    //Placeholders
    if (units == nil)
    {
        units = @"";
    }
    else
    {
        units = [NSString stringWithFormat:@" %@", units];
    }
    
    //Number formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //Formates a zero number for replacing empty values in range
    NSNumber *zeroNumber = [[NSNumber alloc] initWithInteger:0];
    NSString *formattedZero = [formatter stringFromNumber:zeroNumber];
    [zeroNumber release];
    
    //Formats min and max numbers
    NSString *formattedMin = [formatter stringFromNumber:min];
    NSString *formattedMax = [formatter stringFromNumber:max];
    
    [formatter release];
    
    //Returns range based on which values were provided
    if (min == nil && max == nil)
    {
        return [NSString stringWithFormat:@"%@+%@", formattedZero, units];
    }
    else if (min == nil)
    {
        return [NSString stringWithFormat:@"%@ - %@%@", formattedZero, formattedMax, units];
    }
    else if (max == nil)
    {
        return [NSString stringWithFormat:@"%@+%@", formattedMin, units];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ - %@%@", formattedMin, formattedMax, units];
    }
}

- (NSString *)formatCurrencyRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max
{
    //Currency formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMinimumFractionDigits:0];
    
    //Formates a zero number for replacing empty values in range
    NSNumber *zeroNumber = [[NSNumber alloc] initWithInteger:0];
    NSString *formattedZero = [formatter stringFromNumber:zeroNumber];
    [zeroNumber release];
    
    //Formats min and max numbers
    NSString *formattedMin = [formatter stringFromNumber:min];
    NSString *formattedMax = [formatter stringFromNumber:max];
    
    [formatter release];
    
    //Returns range based on which values were provided
    if (min == nil && max == nil)
    {
        return [NSString stringWithFormat:@"%@+", formattedZero];
    }
    else if (min == nil)
    {
        return [NSString stringWithFormat:@"%@ - %@", formattedZero, formattedMax];
    }
    else if (max == nil)
    {
        return [NSString stringWithFormat:@"%@+", formattedMin];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ - %@", formattedMin, formattedMax];
    }
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
    [[self criteria] setPostalCode:[[[self postalCode] postalCode] stringValue]];
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
                [[[self inputRangeCell] minRange] setText:[[[self criteria] minPrice] stringValue]];
                [[[self inputRangeCell] maxRange] setText:[[[self criteria] maxPrice] stringValue]];
            }
            else if ([rowId isEqual:kSquareFeet])
            {
                [[[self inputRangeCell] minRange] setText:[[[self criteria] minSquareFeet] stringValue]];
                [[[self inputRangeCell] maxRange] setText:[[[self criteria] maxSquareFeet] stringValue]];
            }
            else if ([rowId isEqual:kBedrooms])
            {
                [[[self inputRangeCell] minRange] setText:[[[self criteria] minBedrooms] stringValue]];
                [[[self inputRangeCell] maxRange] setText:[[[self criteria] maxBedrooms] stringValue]];
            }
            else if ([rowId isEqual:kBathrooms])
            {
                [[[self inputRangeCell] minRange] setText:[[[self criteria] minBathrooms] stringValue]];
                [[[self inputRangeCell] maxRange] setText:[[[self criteria] maxBathrooms] stringValue]];
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
        //Prevents selection background popping up quickly when pressed. Sometimes it's too quick to see, but this prevents it from showing up at all.
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //Since reusing cells, need to reset this to None
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
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
            [[cell detailTextLabel] setText:[self formatCurrencyRangeWithMin:[[self criteria] minPrice] withMax:[[self criteria] maxPrice]]];
        }
        else if ([rowId isEqual:kSquareFeet])
        {
            [[cell textLabel] setText:@"sq feet"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minSquareFeet] withMax:[[self criteria] maxSquareFeet] withUnits:@"sqft"]];
        }
        else if ([rowId isEqual:kBedrooms])
        {
            [[cell textLabel] setText:@"bedrooms"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minBedrooms] withMax:[[self criteria] maxBedrooms] withUnits:@"rooms"]];
        }
        else if ([rowId isEqual:kBathrooms])
        {
            [[cell textLabel] setText:@"bathrooms"];
            [[cell detailTextLabel] setText:[self formatRangeWithMin:[[self criteria] minBathrooms] withMax:[[self criteria] maxBathrooms] withUnits:@"baths"]];
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
    //If currently editing an input field, returns that text field.
    //This fixes all sorts of quacky issues when the user does not manually press Return
    if ([self currentTextField] != nil)
    {
        [self textFieldShouldReturn:[self currentTextField]];
    }

    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    
    //Selected the search button, begins searching
    if ([rowId isEqual:kSearch])
    {
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
    
    //Sets the correct Criteria attribute to the inputted valu
    if ([rowId isEqual:kLocation])
    {
        [[self criteria] setStreet:text];
    }
    else if ([rowId isEqual:kPrice])
    {
        //Why not create this Number earlier for all to share? Because could be initializing from an int or a float (like Bathrooms).
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        //Tag values set in the Xib are used to distinguish between the min and max input text fields
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinPrice:number];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxPrice:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kSquareFeet])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinSquareFeet:number];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxSquareFeet:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kBedrooms])
    {
        NSNumber *number = [[NSNumber alloc] initWithInteger:[text integerValue]];
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinBedrooms:number];
        }
        else if ([textField tag] == kMaxTag)
        {
            [[self criteria] setMaxBedrooms:number];
        }
        [number release];
    }
    else if ([rowId isEqual:kBathrooms])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        if ([textField tag] == kMinTag)
        {
            [[self criteria] setMinBathrooms:number];
        }
        else if ([textField tag] == kMaxTag)
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
