#import "MortgageCriteriaViewController.h"

#import "AppDelegate.h"
#import "MortgageCriteriaConstants.h"
#import "MortgageUrlConstructor.h"
#import "MortgageResultsViewController.h"
#import "StringFormatter.h"
#import "InputRangeCell.h";
#import "InputSimpleCell.h";
#import "LocationParser.h";


@interface MortgageCriteriaViewController ()
@property (nonatomic, retain, readwrite) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *mortgageStoreCoordinator;
- (void)calculateCashDown;
- (void)calculateLoanAmount;
- (void)calculatePercentDown;
- (void)calculatePurchasePrice;
@end


@implementation MortgageCriteriaViewController

@synthesize criteria = criteria_;
@synthesize mortgageObjectModel = mortgageObjectModel_;
@synthesize mortgageObjectContext = mortgageObjectContext_;
@synthesize mortgageStoreCoordinator = mortgageStoreCoordinator_;


#pragma mark -
#pragma mark MortgageCriteriaViewController

- (void)dealloc
{
    [criteria_ release];
    [mortgageObjectModel_ release];
    [mortgageObjectContext_ release];
    [mortgageStoreCoordinator_ release];
    
    [super dealloc];
}

- (void)calculateCashDown
{
    float purchasePrice = [[[self criteria] purchasePrice] floatValue];
    float percentDown = [[[self criteria] percentDown] floatValue] * (float).01;
    
    NSNumber *cashDown = [[NSNumber alloc] initWithFloat:(purchasePrice * percentDown)];
    [[self criteria] setCashDown:cashDown];
    [cashDown release];
}

- (void)calculateLoanAmount
{
    float purchasePrice = [[[self criteria] purchasePrice] floatValue];
    //Cash down is more accurate than percent down, so use that
    float cashDown = [[[self criteria] cashDown] floatValue];
    
    NSNumber *loanAmount = [[NSNumber alloc] initWithFloat:(purchasePrice - cashDown)];
    [[self criteria] setLoanAmount:loanAmount];
    [loanAmount release];    
}

- (void)calculatePercentDown
{
    float purchasePrice = [[[self criteria] purchasePrice] floatValue];
    float cashDown = [[[self criteria] cashDown] floatValue];
    
    NSNumber *percentDown = [[NSNumber alloc] initWithFloat:(((float) cashDown / purchasePrice) * (float)100.0)];
    // percentDown can become NaN if the user sets percent down to 0 and cash down to 0
    if(isnan([percentDown doubleValue]))
    {
        percentDown = [NSNumber numberWithInt:0];
    }
    [[self criteria] setPercentDown:percentDown];
    [percentDown release];
}

- (void)calculatePurchasePrice
{
    float loanAmount = [[[self criteria] loanAmount] floatValue];
    float percentDown = [[[self criteria] percentDown] floatValue] * (float).01;
    
    NSNumber *purchasePrice = [[NSNumber alloc] initWithFloat:(loanAmount / (1 - percentDown))];
    [[self criteria] setPurchasePrice:purchasePrice];
    [purchasePrice release];
}

- (MortgageCriteria *)criteria
{
    if (criteria_ == nil)
    {
        //Fetches existing Mortgage Criteria if it exists
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *criteriaEntity = [NSEntityDescription entityForName:@"MortgageCriteria" inManagedObjectContext:[self mortgageObjectContext]];
        [fetchRequest setEntity:criteriaEntity];
        
        [fetchRequest setFetchLimit:1];
        
        NSError *error = nil;
        NSArray *fetchResults = [[self mortgageObjectContext] executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        if (fetchResults == nil)
        {
            // Handle the error.
            DebugLog(@"Error fetching Mortgage Criteria object.");
            
            return nil;
        }
        
        //No Criteria, creates a new one
        if ([fetchResults count] == 0)
        {
            //Creates Criteria object to hold all the user input
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"MortgageCriteria" inManagedObjectContext:[self mortgageObjectContext]];
            MortgageCriteria *criteria = [[MortgageCriteria alloc] initWithEntity:entity insertIntoManagedObjectContext:[self mortgageObjectContext]];
            [self setCriteria:criteria];
            [criteria release];
        }
        //Gets existing Criteria
        else
        {
            [self setCriteria:[fetchResults objectAtIndex:0]];
        }
    }
    
    return criteria_;
}

- (void)setProperty:(PropertySummary *)property
{
    // Sets postal code
    NSString *location = [property location];
    LocationParser *parser = [[LocationParser alloc] initWithLocation:location];
    NSString *postalCode = [parser postalCode];
    [parser release];
    if (![postalCode isEqual:@""])
    {
        [[self criteria] setPostalCode:postalCode];
    }
    
    // Sets price
    NSNumber *price = [property price];
    if (price != nil)
    {
        [[self criteria] setPurchasePrice:price];
        
        // Update dependent values
        [self calculateCashDown];
        [self calculateLoanAmount];        
    }
}

- (NSManagedObjectModel *)mortgageObjectModel
{
    if (mortgageObjectModel_ == nil)
    {
        NSString *modelPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Mortgage" ofType:@"mom"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        [self setMortgageObjectModel:managedObjectModel];
        [managedObjectModel release];
    }
    
    return mortgageObjectModel_;
}

- (NSManagedObjectContext *)mortgageObjectContext
{
    if (mortgageObjectContext_ == nil)
    {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setMortgageObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self mortgageObjectContext] setPersistentStoreCoordinator:[self mortgageStoreCoordinator]];
    }
    
    return mortgageObjectContext_;
}

- (NSPersistentStoreCoordinator *)mortgageStoreCoordinator
{
    if (mortgageStoreCoordinator_ == nil)
    {    
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mortgageObjectModel]];
        [self setMortgageStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];
        NSURL *storeUrl = [NSURL fileURLWithPath:[[AppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"Mortgage.sqlite"]];
        NSError *error;
        if (![[self mortgageStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            DebugLog(@"Error adding persistent store coordinator for Mortgage model");
        }    
    }
    
    return mortgageStoreCoordinator_;
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Row Ids outlines the order of the rows in the table. The integer value of each constant does NOT impact the order.
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kMortgageCriteriaPostalCode, kMortgageCriteriaPrice, kMortgageCriteriaPercentDown, kMortgageCriteriaCashDown, kMortgageCriteriaLoanAmount, kMortgageCriteriaLoanTerm, kMortgageCriteriaInterestRate, kMortgageCriteriaCalculate, nil];
    [self setRowIds:rowIds];
    [rowIds release];
}


#pragma mark -
#pragma mark UITableViewDataSource

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
            return [self cellWithNumericInputAndValue:[[self criteria] postalCode]];
        }
        else
        {
            NSString *postalCode = @"(optional)";
            if ([[self criteria] postalCode] != nil && [[[self criteria] postalCode] length] > 0)
            {
                postalCode = [[self criteria] postalCode];
            }
            
            return [self simpleCellWithText:@"zip code" withDetail:postalCode];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaPrice])
    {
        if (isSelectedRow)
        {
            NSString *price = [[[self criteria] purchasePrice] stringValue];
            
            return [self cellWithNumericInputAndValue:price];
        }
        else
        {
            NSString *price = [StringFormatter formatCurrency:[[self criteria] purchasePrice]];
            
            return [self simpleCellWithText:@"price" withDetail:price];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaPercentDown])
    {
        if (isSelectedRow)
        {
            NSString *percentDown = [[[self criteria] percentDown] stringValue];

            return [self cellWithNumericInputAndValue:percentDown];
        }
        else
        {
            NSString *percentDown = [NSString stringWithFormat:@"%@%%", [StringFormatter formatNumber:[[self criteria] percentDown]]];
                        
            return [self simpleCellWithText:@"% down" withDetail:percentDown];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaCashDown])
    {
        if (isSelectedRow)
        {
            NSString *cashDown = [[[self criteria] cashDown] stringValue];

            return [self cellWithNumericInputAndValue:cashDown];
        }
        else
        {
            NSString *cashDown = [StringFormatter formatCurrency:[[self criteria] cashDown]];
            
            return [self simpleCellWithText:@"cash down" withDetail:cashDown];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanAmount])
    {
        if (isSelectedRow)
        {
            NSString *loanAmount = [[[self criteria] loanAmount] stringValue];
            
            return [self cellWithNumericInputAndValue:loanAmount];
        }
        else
        {
            NSString *loanAmount = [StringFormatter formatCurrency:[[self criteria] loanAmount]];
            
            return [self simpleCellWithText:@"loan amt" withDetail:loanAmount];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanTerm])
    {
        if (isSelectedRow)
        {
            NSString *loanTerm = [[[self criteria] loanTerm] stringValue];
            
            return [self cellWithNumericInputAndValue:loanTerm];
        }
        else
        {
            NSString *loanTerm = @"(optional)";
            if ([[self criteria] loanTerm] != nil && [[[self criteria] loanTerm] floatValue] > 0)
            {
                loanTerm = [NSString stringWithFormat:@"%@ years", [StringFormatter formatNumber:[[self criteria] loanTerm]]];
            }
            
            return [self simpleCellWithText:@"loan term" withDetail:loanTerm];
        }
    }
    else if ([rowId isEqual:kMortgageCriteriaInterestRate])
    {
        if (isSelectedRow)
        {
            NSString *interestRate = [[[self criteria] interestRate] stringValue];
            
            return [self cellWithNumericInputAndValue:interestRate];
        }
        else
        {
            NSString *interestRate = @"(optional)";
            if ([[self criteria] interestRate] != nil && [[[self criteria] interestRate] floatValue] > 0)
            {
                interestRate = [NSString stringWithFormat:@"%@%%", [StringFormatter formatNumber:[[self criteria] interestRate]]];
            }
            
            return [self simpleCellWithText:@"rate" withDetail:interestRate];
        }
    }
    //Button cell
    else if ([rowId isEqual:kMortgageCriteriaCalculate])
    {
        return [self buttonCellWithText:@"calculate"];
    }
    
    return nil;
}

- (InputSimpleCell *)cellWithNumericInputAndValue:(NSString *)value
{
    InputSimpleCell *cell = [self inputSimpleCellWithText:value];
    [[cell input] setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    return cell;
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
        //Validates input
        if ([[self criteria] purchasePrice] == nil || [[[self criteria] purchasePrice] floatValue] <= 0.0)
        {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"Purchase price must be set."
                                                                delegate:self 
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
            [errorAlert show];
            [errorAlert release];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            return;
        }
        
        //Saves Criteria
        NSManagedObjectContext *managedObjectContext = [[self criteria] managedObjectContext];
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving context.");
        }
        
        MortgageResultsViewController *resultsViewController = [[MortgageResultsViewController alloc] initWithNibName:@"MortgageResultsView" bundle:nil];
        
        [resultsViewController setCriteria:[self criteria]];
        
        //Turns Criteria into URL then parses
        MortgageUrlConstructor *urlConstructor = [[MortgageUrlConstructor alloc] init];
        NSURL *url = [urlConstructor urlFromCriteria:[self criteria]];
        [urlConstructor release];
        [resultsViewController parse:url];
        
        [[self navigationController] pushViewController:resultsViewController animated:YES];
        [resultsViewController release];        
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *rowId = [[self rowIds] objectAtIndex:[self selectedRow]];
    NSString *text = [textField text];
    
    //Sets the correct Criteria attribute to the inputted valu
    if ([rowId isEqual:kMortgageCriteriaPostalCode])
    {
        [[self criteria] setPostalCode:text];
    }
    else if ([rowId isEqual:kMortgageCriteriaPrice])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setPurchasePrice:number];
        [number release];
        
        //Update dependent values
        [self calculateCashDown];
        [self calculateLoanAmount];
    }
    else if ([rowId isEqual:kMortgageCriteriaPercentDown])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setPercentDown:number];
        [number release];
        
        //Update dependent values
        [self calculateCashDown];
        [self calculateLoanAmount];
    }
    else if ([rowId isEqual:kMortgageCriteriaCashDown])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setCashDown:number];
        [number release];
        
        //Update dependent values
        [self calculatePercentDown];
        [self calculateLoanAmount];
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanAmount])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setLoanAmount:number];
        [number release];
        
        //Update dependent values
        [self calculatePurchasePrice];
        [self calculateCashDown];
    }
    else if ([rowId isEqual:kMortgageCriteriaLoanTerm])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setLoanTerm:number];
        [number release];
    }
    else if ([rowId isEqual:kMortgageCriteriaInterestRate])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[text floatValue]];
        [[self criteria] setInterestRate:number];
        [number release];
    }    
    
    [self setCurrentTextField:nil];
    
    //Exits edit mode and displays updated field
    [self setSelectedRow:-1];
    [[self tableView] reloadData];
}

@end
