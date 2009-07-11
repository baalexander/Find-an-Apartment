#import "MortgageCriteriaViewController.h"

#import "HomeFinderAppDelegate.h"
#import "MortgageCriteriaConstants.h"
#import "InputRangeCell.h";
#import "InputSimpleCell.h";


@interface MortgageCriteriaViewController ()
@property (nonatomic, retain, readwrite) NSManagedObjectModel *mortgageObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *mortgageObjectContext;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *mortgageStoreCoordinator;
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
    [mortgageObjectModel_ release];
    [mortgageObjectContext_ release];
    [mortgageStoreCoordinator_ release];
    
    [super dealloc];
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
        NSURL *storeUrl = [NSURL fileURLWithPath:[[HomeFinderAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"Mortgage.sqlite"]];
        NSError *error;
        if (![[self mortgageStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
        {
            NSLog(@"Error adding persistent store coordinator for Mortgage model");
            //TODO: Handle error
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
    NSMutableArray *rowIds = [[NSMutableArray alloc] initWithObjects:kMortgageCriteriaPostalCode, kMortgageCriteriaPrice, kMortgageCriteriaPercentDown, kMortgageCriteriaCashDown, kMortgageCriteriaLoanAmount, kMortgageCriteriaLoanTerm, kMortgageCriteriaLoanRate, kMortgageCriteriaCalculate, nil];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setCurrentTextField:nil];
}

@end
