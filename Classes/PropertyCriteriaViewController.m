#import "PropertyCriteriaViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "PropertyHistoryViewController.h"
#import "PropertyCriteriaConstants.h"
#import "InputRangeCell.h"
#import "InputSimpleCell.h"
#import "PropertyUrlConstructor.h"
#import "PropertyResultsViewController.h"
#import "PropertySortChoicesViewController.h"
#import "StringFormatter.h"
#import "SaveAndRestoreConstants.h"

#ifdef HOME_FINDER
    #import "PropertySearchSourcesViewController.h"
#endif


@interface PropertyCriteriaViewController ()
@property (nonatomic, retain) PropertyCriteria *criteria;
@end


@implementation PropertyCriteriaViewController

@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize criteria = criteria_;


#pragma mark -
#pragma mark PropertyCriteriaViewController

- (void)dealloc
{
    [propertyObjectContext_ release];    
    [criteria_ release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Gets most recent Property Criteria from most recent History to pre-populate non-geographic criteria
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:[self propertyObjectContext]];
    [fetchRequest setEntity:entity];
    
    //Sorts so most recent is first
    NSSortDescriptor *createdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:createdDescriptor, nil];
    [createdDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isFavorite == NO)"];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchResults = [[self propertyObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //No recent History object to get Criteria from, creates Criteria
    if (fetchResults == nil || [fetchResults count] == 0)
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PropertyCriteria" inManagedObjectContext:[self propertyObjectContext]];
        PropertyCriteria *criteria = [[PropertyCriteria alloc] initWithEntity:entity insertIntoManagedObjectContext:[self propertyObjectContext]];
        [self setCriteria:criteria];
        [criteria release];            
    }
    //Gets most recent Criteria object from History
    else
    {
        PropertyHistory *history = [fetchResults objectAtIndex:0];
        [self setCriteria:[history criteria]];
    }

    //Fills criteria in with saved information
    [[self criteria] setState:[[NSUserDefaults standardUserDefaults] objectForKey:kSavedState]];
    [[self criteria] setCity:[[NSUserDefaults standardUserDefaults] objectForKey:kSavedCity]];
    [[self criteria] setPostalCode:[[NSUserDefaults standardUserDefaults] objectForKey:kSavedPostalCode]];
    //Street could be set when searching by location
    [[self criteria] setStreet:[[NSUserDefaults standardUserDefaults] objectForKey:kSavedStreet]];
    
    //Sets coordinate details
    NSNumber *latitude = [[NSNumber alloc] initWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:kSavedLatitude]];
    [[self criteria] setLatitude:latitude];
    [latitude release];
    NSNumber *longitude = [[NSNumber alloc] initWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:kSavedLongitude]];
    [[self criteria] setLongitude:longitude];
    [longitude release];

    //Sets title to location
    NSString *title;
    if ([[self criteria] city] != nil && [[[self criteria] city] length] > 0)
    {
        title = [[self criteria] city];
    }
    else if ([[self criteria] state] != nil && [[[self criteria] state] length] > 0)
    {
        title = [[self criteria] state];
    }
    else
    {
        title = @"Criteria";
    }
    [self setTitle:title];
    
    //Row Ids outlines the order of the rows in the table
    //Different for each app
    NSArray *rowIds;
#ifdef HOME_FINDER
    rowIds = [[NSArray alloc] initWithObjects:kPropertyCriteriaSearchSource, kPropertyCriteriaPostalCode, kPropertyCriteriaKeywords, kPropertyCriteriaPrice, kPropertyCriteriaSquareFeet, kPropertyCriteriaBedrooms, kPropertyCriteriaSortBy, kPropertyCriteriaSearch, nil];
#else
    rowIds = [[NSArray alloc] initWithObjects:kPropertyCriteriaPostalCode, kPropertyCriteriaKeywords, kPropertyCriteriaPrice, kPropertyCriteriaSquareFeet, kPropertyCriteriaBedrooms, kPropertyCriteriaBathrooms, kPropertyCriteriaSortBy, kPropertyCriteriaSearch, nil];
#endif
    [self setRowIds:rowIds];
    [rowIds release];
}

- (void)viewDidUnload
{
    
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowId = [[self rowIds] objectAtIndex:[indexPath row]];
    //If this cell is the selected cell, then returns a cell for inputting
    //The reason for the > 0 and NSInteger cast is because comparing signed to unsigned integer
    BOOL isSelectedRow = [self selectedRow] >= 0 && [self selectedRow] == (NSInteger)[indexPath row];
    
    //When selected, these cells display a simple input cell
    if ([rowId isEqual:kPropertyCriteriaPostalCode])
    {
        if (isSelectedRow)
        {
            return [self inputSimpleCellWithText:[[self criteria] postalCode]];
        }
        else
        {
            NSString *detailText = @"(optional)";
            if ([[self criteria] postalCode] != nil && [[[self criteria] postalCode] length] > 0)
            {
                detailText = [[self criteria] postalCode];
            }
            
            return [self simpleCellWithText:@"zip code" withDetail:detailText];
        }
    }
    else if ([rowId isEqual:kPropertyCriteriaKeywords])
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
    else if ([rowId isEqual:kPropertyCriteriaPrice])
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
    else if ([rowId isEqual:kPropertyCriteriaSquareFeet])
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
    else if ([rowId isEqual:kPropertyCriteriaBedrooms])
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
    else if ([rowId isEqual:kPropertyCriteriaBathrooms])
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
    else if ([rowId isEqual:kPropertyCriteriaSortBy])
    {
        UITableViewCell *cell = [self simpleCellWithText:@"sort by" withDetail:[[self criteria] sortBy]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        
        return cell;
    }
#ifdef HOME_FINDER
    else if ([rowId isEqual:kPropertyCriteriaSearchSource])
    {
        UITableViewCell *cell = [self simpleCellWithText:@"source" withDetail:[[self criteria] searchSource]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        
        return cell;
    }    
#endif
    
    else if ([rowId isEqual:kPropertyCriteriaSearch])
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
    if ([rowId isEqual:kPropertyCriteriaSearch])
    {
        //Saves some geography criteria information not saved by the States or Cities view controller
        [[NSUserDefaults standardUserDefaults] setObject:[[self criteria] postalCode] forKey:kSavedPostalCode];
        
        PropertyResultsViewController *resultViewController = [[PropertyResultsViewController alloc] initWithNibName:@"PropertyResultsView" bundle:nil];
        
        //Sets History
        PropertyHistory *history = [PropertyHistoryViewController historyWithCopyOfCriteria:[self criteria]];
        [history setTitle:[self title]];
        [resultViewController setHistory:history];
        [history release];
        
        //Turns Criteria into URL then parses
        PropertyUrlConstructor *urlConstructor = [[PropertyUrlConstructor alloc] init];
        NSURL *url = [urlConstructor urlFromCriteria:[self criteria]];
        [urlConstructor release];
        [resultViewController parse:url];

        [[self navigationController] pushViewController:resultViewController animated:YES];
        [resultViewController release];
    }
    //Selected sort by, brings up list of sort choices
    else if ([rowId isEqual:kPropertyCriteriaSortBy]) 
    {
        PropertySortChoicesViewController *choicesViewController = [[PropertySortChoicesViewController alloc] initWithNibName:@"PropertySortChoicesView" bundle:nil];
        [choicesViewController setCriteria:[self criteria]];
#ifdef HOME_FINDER
        //Trulia has different sort choices
        if ([[[self criteria] searchSource] isEqual:kPropertyCriteriaTrulia])
        {
            NSArray *sortChoices = [[NSArray alloc] initWithObjects:kPropertyCriteriaSortByPriceAscending, kPropertyCriteriaSortByPriceDescending, kPropertyCriteriaSortByBestMatch, nil];
            [choicesViewController setChoices:sortChoices];
            [sortChoices release];
        }
#endif
        [[self navigationController] pushViewController:choicesViewController animated:YES];
        [choicesViewController release];
    }
#ifdef HOME_FINDER
    //Selected search source, brings up list of search sources
    else if ([rowId isEqual:kPropertyCriteriaSearchSource]) 
    {
        PropertySearchSourcesViewController *choicesViewController = [[PropertySearchSourcesViewController alloc] initWithNibName:@"PropertySearchSourcesView" bundle:nil];
        [choicesViewController setCriteria:[self criteria]];
        [[self navigationController] pushViewController:choicesViewController animated:YES];
        [choicesViewController release];
    }    
#endif
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
    
    BOOL isSimpleInputCell = NO;
    
    //Sets the correct Criteria attribute to the inputted valu
    if ([rowId isEqual:kPropertyCriteriaPostalCode])
    {
        [[self criteria] setPostalCode:text];
        isSimpleInputCell = YES;
    }
    else if ([rowId isEqual:kPropertyCriteriaKeywords])
    {
        [[self criteria] setKeywords:text];
        isSimpleInputCell = YES;
    }
    else if ([rowId isEqual:kPropertyCriteriaPrice])
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
    else if ([rowId isEqual:kPropertyCriteriaSquareFeet])
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
    else if ([rowId isEqual:kPropertyCriteriaBedrooms])
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
    else if ([rowId isEqual:kPropertyCriteriaBathrooms])
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
    
    //Exits edit mode and displays updated field ONLY IF NOT A RANGE INPUT. Range input would cause changing from min to max inputs to go out of edit mode.
    if (isSimpleInputCell)
    {
        [self setSelectedRow:-1];
        [[self tableView] reloadData];        
    }
}

@end
