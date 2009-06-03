#import "PropertyCriteriaViewController.h"

#import "FindAnApartmentAppDelegate.h"
#import "InputRangeCell.h"
#import "InputSimpleCell.h"


@interface PropertyCriteriaViewController ()
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) PropertyCriteria *criteria;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL isEditingRow;
@property (nonatomic, retain) NSMutableArray *rowIds;
@end


static NSString *kSource = @"SOURCE";
static NSString *kLocation = @"LOCATION";
static NSString *kPrice = @"PRICE";
static NSString *kSquareFeet = @"SQUARE_FEET";
static NSString *kBedrooms = @"BEDROOMS";
static NSString *kBathrooms = @"BATHROOMS";
static NSString *kSortBy = @"SORT_BY";
static NSString *kSearch = @"SEARCH";


@implementation PropertyCriteriaViewController

@synthesize currentTextField = currentTextField_;
@synthesize criteria = criteria_;
@synthesize selectedRow = selectedRow_;
@synthesize isEditingRow = isEditingRow_;
@synthesize inputRangeCell = inputRangeCell_;
@synthesize inputSimpleCell = inputSimpleCell_;
@synthesize rowIds = rowIds_;
@synthesize state = state_;
@synthesize city = city_;
@synthesize postalCode = postalCode_;

- (void)dealloc
{
    [state_ release];
    [city_ release];
    [postalCode_ release];
    [inputRangeCell_ release];
    [inputSimpleCell_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark PropertyCriteriaViewController

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
        return [NSString stringWithFormat:@"%@0-%@%@%@", symbol, symbol, formattedMax, units];
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


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sets title to location
    NSString *title;
    if ([self postalCode] != nil)
    {
        title = [self postalCode];
    }
    else if ([self city] != nil && [self state] != nil)
    {
        title = [NSString stringWithFormat:@"%@, %@", [self city], [self state]];
    }
    else
    {
        title = @"Criteria";
    }
    [self setTitle:title];
    
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kSource, kLocation, kPrice, kSquareFeet, kBedrooms, kBathrooms, kSortBy, kSearch, nil];
    [self setRowIds:rowIds];
    [rowIds release];
    
    FindAnApartmentAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSEntityDescription *criteriaEntity = [[[appDelegate managedObjectModel] entitiesByName] objectForKey:@"PropertyCriteria"];
    PropertyCriteria *criteria = [[PropertyCriteria alloc] initWithEntity:criteriaEntity insertIntoManagedObjectContext:[appDelegate managedObjectContext]];
    [self setCriteria:criteria];
    [criteria release];
    
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
static NSInteger kMinTag = 0;
static NSInteger kMaxTag = 1;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self rowIds] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    
    //Returns input cell
    if ([indexPath row] == [self selectedRow])
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
    //Returns simple cell
    else if ([indexPath row] < [[self rowIds] count] - 1)
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
            if ([[self criteria] street] == nil)
            {
                [[cell detailTextLabel] setText:@""];
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
    //Last row is a button
    else
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
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Last cell acts as a search button
    if ([indexPath row] == [[self rowIds] count] - 1)
    {
        //TODO Push results
    }
    else
    {
        //If pressing a row that's already in edit mode (was selected last), then resets to unedit mode
        if ([indexPath row] == [self selectedRow])
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
