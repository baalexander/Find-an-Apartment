#import "PropertyListEmailerViewController.h"

#import "PropertySummary.h"


@interface PropertyListEmailerViewController ()
- (NSString *)propertyToHtml:(PropertySummary *)summary;
@end


@implementation PropertyListEmailerViewController

@synthesize properties = properties_;


#pragma mark -
#pragma mark PropertyListEmailerViewController

- (void)setProperties:(NSArray *)properties
{
    [properties retain];
    [properties_ release];
    properties_ = properties;
    
    //No email to construct if no properties
    if ([self properties] == nil)
    {
        return;
    }
    
    NSMutableString *body = [[NSMutableString alloc] init];
    //Singular or plural
    if ([[self properties] count] == 1)
    {
        [self setSubject:@"Property found on Find an Apartment"];
        [body appendString:@"<p>Property to check out:</p>"];
    }
    else
    {
        [self setSubject:@"Properties found on Find an Apartment"];
        [body appendString:@"<p>Properties to check out:</p>"];
    }
    
    //Creates list of properties formatted in HTML
    [body appendString:@"<ul>"];
    for (PropertySummary *summary in properties)
    {
        [body appendFormat:@"<li>%@</li>", [self propertyToHtml:summary]];
    }
    [body appendString:@"</ul>"];
    
    [self setMessageBody:body isHTML:YES];
    [body release];
}

- (NSString *)propertyToHtml:(PropertySummary *)summary
{
    NSMutableString *body = [NSMutableString string];
	[body appendFormat:@"<a href=\"%@\">%@</a><br/>", [summary link], [summary title]];
	
	if ([summary subtitle] != nil && [[summary subtitle] length] > 0)
	{
		[body appendFormat:@"%@<br/>", [summary subtitle]];
	}
	if ([summary price] != nil && [summary price]  > 0)
	{
        //Formats NSNumber as currency with no cents
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setMinimumFractionDigits:0];
        [body appendFormat:@"%@<br/>", [formatter stringFromNumber:[summary price]]];
        [formatter release];
	}
	if ([summary summary] != nil && [[summary summary] length] > 0)
	{
		[body appendFormat:@"%@<br/>", [summary summary]];
	}
    
    return body;
}


#pragma mark -
#pragma mark UINavigationController

- (void)viewDidLoad
{
    //Styles view controller to resemble the rest of the app
    [[self navigationBar] setTintColor:[UIColor blackColor]];
}

@end
