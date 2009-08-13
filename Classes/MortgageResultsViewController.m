#import "MortgageResultsViewController.h"

#import "MortgageResultsConstants.h"
#import "StringFormatter.h"


//Element name that separates each item in the XML results
static const char *kItemName = "loan";


@interface MortgageResultsViewController ()
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, retain) NSMutableArray *loans;
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@property (nonatomic, retain) NSMutableDictionary *loan;
- (void)calculateCustomLoan;
@end


@implementation MortgageResultsViewController

@synthesize operationQueue = operationQueue_;
@synthesize isParsing = isParsing_;
@synthesize loans = loans_;
@synthesize sectionTitles = sectionTitles_;
@synthesize loan = loan_;
@synthesize criteria = criteria_;


#pragma mark -
#pragma mark MortgageResultsViewController

- (void)dealloc
{
    [operationQueue_ release];
    [sectionTitles_ release];
    [loan_ release];
    [criteria_ release];
    
    [super dealloc];
}

- (void)calculateCustomLoan
{
    if ([[self criteria] loanAmount] == nil || [[self criteria] loanTerm] == nil || [[self criteria] interestRate] == nil)
    {
        return;
    }
    
    //Principal
    float loanAmount = [[[self criteria] loanAmount] floatValue];
    //Term = years
	float loanTerm = [[[self criteria] loanTerm] floatValue];
    //Interest rate
	float interestRate = [[[self criteria] interestRate] floatValue];
	//12 = monthly
	NSInteger paymentFrequency = 12;
	//Monthly interest rate = rate divided by 100 to turn into percentage then divided by payments per year
	float monthlyInterestRate = interestRate / 100 / paymentFrequency;
	//Payment formula: c = (r / (1 − (1 + r)^−N) ) * P 
	float payment = (float)(monthlyInterestRate / (1 - pow(1 + monthlyInterestRate, -loanTerm * paymentFrequency)) * loanAmount);
    
    //Adds values as Loan to results
    NSMutableDictionary *loan = [[NSMutableDictionary alloc] init];
    [loan setObject:[NSString stringWithFormat:@"%.2f", interestRate] forKey:kMortgageResultsRate];
    [loan setObject:[NSString stringWithFormat:@"%.1f", loanTerm] forKey:kMortgageResultsTerm];
    [loan setObject:[NSString stringWithFormat:@"%f", payment] forKey:kMortgageResultsPayment];
    [[self loans] insertObject:loan atIndex:0];
    [loan release];
    
    [[self sectionTitles] insertObject:@"Custom loan" atIndex:0];
}

- (void)parse:(NSURL *)url
{
    [self setIsParsing:YES];
    
    NSMutableArray *loans = [[NSMutableArray alloc] init];
    [self setLoans:loans];
    [loans release];
    
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    [self setSectionTitles:sectionTitles];
    [sectionTitles release];
    
    // Create the parser, set its delegate, and start it.
    XmlParser *parser = [[XmlParser alloc] init];
    [parser setDelegate:self];
    [parser setUrl:url];
    [parser setItemDelimiter:kItemName];
    
    //Add the Parser to an operation queue for background processing (works on a separate thread)
    [[self operationQueue] addOperation:parser];
    [parser release];
    
    //Calculates custom loan from user input
    [self calculateCustomLoan];
}

- (NSOperationQueue *)operationQueue
{
    if (operationQueue_ == nil)
    {
        operationQueue_ = [[NSOperationQueue alloc] init];
    }
    
    return operationQueue_;
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Loan Results"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Cancels any operations in the queue. This is for when pressing the back button and dismissing the view controller. This prevents the parser from still running and failing when calling its delegate.
    [[self operationQueue] cancelAllOperations];
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
    return [[self sectionTitles] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kDetailCellId] autorelease];
    }

    NSDictionary *loan = [[self loans] objectAtIndex:[indexPath section]];
    NSString *key = [[loan allKeys] objectAtIndex:[indexPath row]];
    NSString *detail = [loan objectForKey:key];
    
    [[cell textLabel] setText:key];
    
    if ([key isEqual:kMortgageResultsTerm])
    {
        detail = [NSString stringWithFormat:@"%@ years", detail];
    }
    else if ([key isEqual:kMortgageResultsRate])
    {
        detail = [NSString stringWithFormat:@"%@%%", detail];
    }
    else if ([key isEqual:kMortgageResultsPayment])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[detail floatValue]];
        detail = [StringFormatter formatCurrency:number];
        [number release];
    }
    else if ([key isEqual:kMortgageResultsPropertyTaxes])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[detail floatValue]];
        detail = [StringFormatter formatCurrency:number];
        [number release];
    }
    else if ([key isEqual:kMortgageResultsHazardInsurance])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[detail floatValue]];
        detail = [StringFormatter formatCurrency:number];
        [number release];
    }
    else if ([key isEqual:kMortgageResultsMortgageInsurance])
    {
        NSNumber *number = [[NSNumber alloc] initWithFloat:[detail floatValue]];
        detail = [StringFormatter formatCurrency:number];
        [number release];
    }
    
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

- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement
{
    NSString *elementName = [xmlElement name];
    NSString *elementValue = [xmlElement value];
    
    if (elementValue == nil || [elementValue length] == 0)
    {
        return;
    }

    if ([elementName isEqual:@"type"])
    {
        //Sets placeholder section title to type
        [[self sectionTitles] replaceObjectAtIndex:([[self sectionTitles] count] - 1) withObject:elementValue];
    }
    else if ([elementName isEqual:@"rate"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsRate];
    }
    else if ([elementName isEqual:@"term"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsTerm];
    }
    else if ([elementName isEqual:@"monthly_principal_and_interest"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsPayment];
    }
    else if ([elementName isEqual:@"monthly_property_taxes"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsPropertyTaxes];
    }
    else if ([elementName isEqual:@"monthly_hazard_insurance"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsHazardInsurance];
    }    
    else if ([elementName isEqual:@"monthly_mortgage_insurance"])
    {
        [[self loan] setObject:elementValue forKey:kMortgageResultsMortgageInsurance];
    }
}

- (void)parserDidBeginItem:(XmlParser *)parser
{
    NSMutableDictionary *loan = [[NSMutableDictionary alloc] init];
    [self setLoan:loan];
    [loan release];
    
    [[self loans] addObject:[self loan]];
    
    //Adds empty section title as a placeholder to be set later
    [[self sectionTitles] addObject:@""];
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
