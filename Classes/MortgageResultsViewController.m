#import "MortgageResultsViewController.h"


//Element name that separates each item in the XML results
static const char *kItemName = "loan";


@interface MortgageResultsViewController ()
@property (nonatomic, retain) XmlParser *parser;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) NSMutableArray *loans;
@property (nonatomic, retain) NSMutableDictionary *loan;
@end


@implementation MortgageResultsViewController

@synthesize parser = parser_;
@synthesize isParsing = isParsing_;
@synthesize loans = loans_;
@synthesize loan = loan_;


#pragma mark -
#pragma mark MortgageResultsViewController

- (void)dealloc
{
    [parser_ release];
    [loan_ release];
    
    [super dealloc];
}

- (void)parse:(NSURL *)url
{
    [self setIsParsing:YES];
    
    NSMutableArray *loans = [[NSMutableArray alloc] init];
    [self setLoans:loans];
    [loans release];
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [self setParser:parser];
    [parser release];
    [[self parser] setDelegate:self];
    [[self parser] startWithUrl:url withItemDelimeter:kItemName];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Loan Results"];
}


#pragma mark -
#pragma mark UITableViewDataSource

static NSString *kDetailCellId = @"DETAIL_CELL_ID";


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self loans] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *loan = [[self loans] objectAtIndex:section];

    return [[loan allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *loan = [[self loans] objectAtIndex:section];
    
    return [loan objectForKey:@"type"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDetailCellId] autorelease];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    NSDictionary *loan = [[self loans] objectAtIndex:[indexPath section]];
    NSString *key = [[loan allKeys] objectAtIndex:[indexPath row]];
    NSString *detail = [loan objectForKey:key];
    
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:detail];
    
    return cell;
}


#pragma mark -
#pragma mark ParserDelegate

- (void)parserDidEndParsingData:(XmlParser *)parser
{
    [self setIsParsing:NO];
    
    [[self tableView] reloadData];
}

- (void)parser:(XmlParser *)parser addElement:(NSString *)element withValue:(NSString *)value
{
    if (value == nil || [value length] == 0)
    {
        return;
    }

    if ([element isEqual:@"type"])
    {
        [[self loan] setObject:value forKey:@"type"];
    }
    else if ([element isEqual:@"rate"])
    {
        [[self loan] setObject:value forKey:@"rate"];
    }
    else if ([element isEqual:@"term"])
    {
        [[self loan] setObject:value forKey:@"term"];
    }
    else if ([element isEqual:@"monthly_principal_and_interest"])
    {
        [[self loan] setObject:value forKey:@"payment"];
    }
    else if ([element isEqual:@"monthly_property_taxes"])
    {
        [[self loan] setObject:value forKey:@"prop taxes"];
    }
    else if ([element isEqual:@"monthly_hazard_insurance"])
    {
        [[self loan] setObject:value forKey:@"hazard ins"];
    }    
    else if ([element isEqual:@"monthly_mortgage_insurance"])
    {
        [[self loan] setObject:value forKey:@"PMI"];
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    NSMutableDictionary *loan = [[NSMutableDictionary alloc] init];
    [self setLoan:loan];
    [loan release];
    
    [[self loans] addObject:[self loan]];
}

- (void)parserDidEndItem:(XmlParser *)parser
{
    //Currently nothing to do
}

- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error
{
    [self setIsParsing:NO];
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error downloading rates"
                                                         message:[error localizedDescription] 
                                                        delegate:self 
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

@end
