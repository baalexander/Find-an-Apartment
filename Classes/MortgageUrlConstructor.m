#import "MortgageUrlConstructor.h"

#import "MortgageCriteriaConstants.h"
#import "UrlUtil.h"


@interface MortgageUrlConstructor ()
@property (nonatomic, retain) MortgageCriteria *criteria;
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

- (NSURL *)urlFromCriteria:(MortgageCriteria *)criteria
{
    [self setCriteria:criteria];
    
    //Creates base URL
    NSString *baseUrl = @"http://www.alexandermobile.com/real_estate_dev/mortgages/view.xml?";
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:baseUrl];
    
    //Appends device params
    [mutableUrl appendString:[self deviceParams]];
    
    //Appends fields from user input
    
    NSURL *url = [[[NSURL alloc] initWithString:mutableUrl] autorelease];
    NSLog(@"MORTGAGE URL:%@", url);
    [mutableUrl release];
    
    return url;
}

@end
