#import "MortgageUrlConstructor.h"

#import "MortgageCriteriaConstants.h"
#import "UrlUtil.h"


@interface MortgageUrlConstructor ()
@property (nonatomic, retain) MortgageCriteria *criteria;
- (NSString *)postalCode;
- (NSString *)purchasePrice;
- (NSString *)cashDown;
- (NSString *)percentDown;
- (NSString *)loanAmount;
- (NSString *)loanTerm;
- (NSString *)interestRate;
@end


@implementation MortgageUrlConstructor

@synthesize criteria = criteria_;


#pragma mark -
#pragma mark MortgageUrlConstructor

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [criteria_ release];
    
    [super dealloc];
}

- (NSString *)postalCode
{
    return [self parameter:@"postal_code" withValue:[[self criteria] postalCode]];
}

- (NSString *)purchasePrice
{
    return [self parameter:@"purchase_price" withNumericValue:[[self criteria] purchasePrice]];
}

- (NSString *)cashDown
{
    return [self parameter:@"cash_down" withNumericValue:[[self criteria] cashDown]];    
}

- (NSString *)percentDown
{
    return [self parameter:@"percent_down" withNumericValue:[[self criteria] percentDown]];
}

- (NSString *)loanAmount
{
    return [self parameter:@"loan_amount" withNumericValue:[[self criteria] loanAmount]];
}

- (NSString *)loanTerm
{
    return [self parameter:@"loan_term" withNumericValue:[[self criteria] loanTerm]];
}

- (NSString *)interestRate
{
    return [self parameter:@"interest_rate" withNumericValue:[[self criteria] interestRate]];
}

- (NSURL *)urlFromCriteria:(MortgageCriteria *)criteria
{
    [self setCriteria:criteria];
    
    //Creates base URL
    NSString *baseUrl = @"http://www.alexandermobile.com/real_estate/mortgage_loans/view.xml?";
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:baseUrl];
    
    //Appends device params
    [mutableUrl appendString:[self deviceParams]];
    
    //Appends fields from user input
    [mutableUrl appendString:[self postalCode]];
    [mutableUrl appendString:[self purchasePrice]];
    [mutableUrl appendString:[self cashDown]];
    [mutableUrl appendString:[self percentDown]];
    [mutableUrl appendString:[self loanAmount]];
    [mutableUrl appendString:[self loanTerm]];
    [mutableUrl appendString:[self interestRate]];
    
    NSURL *url = [[[NSURL alloc] initWithString:mutableUrl] autorelease];
    DebugLog(@"MORTGAGE URL:%@", url);
    [mutableUrl release];
    
    return url;
}

@end
