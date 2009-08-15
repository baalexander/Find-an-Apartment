#import "WebViewController.h"

#define kWebBack 0
#define kWebForward 1


@interface WebViewController ()
- (void)enableDisableBackFowardButtons:(UISegmentedControl *)segmentedControl;
@end


@implementation WebViewController

@synthesize webView = webView_;
@synthesize url = url_;


- (void)dealloc
{
    [webView_ setDelegate:nil];
    [webView_ release];
    [url_ release];

    [super dealloc];
}

- (IBAction)backForward:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedSegment = [segmentedControl selectedSegmentIndex];
    if (selectedSegment == kWebBack)
    {
        [[self webView] goBack];
    }
    else if (selectedSegment == kWebForward)
    {
        [[self webView] goForward];
    }

    [self enableDisableBackFowardButtons:segmentedControl];
}

- (void)enableDisableBackFowardButtons:(UISegmentedControl *)segmentedControl
{
    [segmentedControl setEnabled:[[self webView] canGoBack] forSegmentAtIndex:kWebBack];
    [segmentedControl setEnabled:[[self webView] canGoForward] forSegmentAtIndex:kWebForward];
}


#pragma mark UIViewController

- (void)viewDidLoad
{    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"back.png"],
                                             [UIImage imageNamed:@"forward.png"],
                                             nil]];
    [segmentedControl addTarget:self action:@selector(backForward:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setMomentary:YES];
    [segmentedControl setEnabled:NO];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
    [[self navigationItem] setRightBarButtonItem:segmentBarItem];
    [segmentBarItem release];
    
    // Setup the UIWebView
    UIWebView *webView = [[UIWebView alloc] init];
    [self setWebView:webView];
    [webView release];
    [[self webView] setDataDetectorTypes:UIDataDetectorTypeAll];
    [[self webView] setScalesPageToFit:YES];
    [[self webView] setDelegate:self];
    
    // Load the page for the given address
    if ([self url] != nil)
    {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self url]];
        [[self webView] loadRequest:request];
        [request release];        
    }
    
    [self setView:[self webView]];    
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Show the network activity indicator while the page is loading
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
    [self enableDisableBackFowardButtons:segmentedControl];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Hide the network activity indicator after the page has loaded
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)[[[self navigationItem] rightBarButtonItem] customView];
    [self enableDisableBackFowardButtons:segmentedControl];
}

@end
