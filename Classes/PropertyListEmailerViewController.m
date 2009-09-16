#import "PropertyListEmailerViewController.h"

#import "PropertySummary.h"
#import "StringFormatter.h"
#import "Constants.h"


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
        NSString *subject = [[NSString alloc] initWithFormat:@"Property found with %@", kAppName];
        [self setSubject:subject];
        [subject release];
        [body appendString:@"<p>Property to check out:</p>"];
    }
    else
    {
        NSString *subject = [[NSString alloc] initWithFormat:@"Properties found with %@", kAppName];
        [self setSubject:subject];
        [subject release];
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
        [body appendFormat:@"%@<br/>", [StringFormatter formatCurrency:[summary price]]];
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
