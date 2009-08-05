#import "WebViewController.h"

#define kWebBack 0
#define kWebForward 1


@implementation WebViewController

@synthesize webView = webView_;

- (id)initWithAddress:(NSString *)address
{
    if((self = [super init]))
    {
        // Setup the navigation and close buttons
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered
                                                                    target:[self parentViewController] action:@selector(dismissModalViewController)];
        [[self navigationItem] setLeftBarButtonItem:closeBtn];
        [closeBtn release];
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"back.png"],
                                                 [UIImage imageNamed:@"forward.png"],
                                                 nil]];
        [segmentedControl addTarget:self action:@selector(backForward:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setFrame:CGRectMake(0, 0, 90, 30)];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentedControl setMomentary:YES];
        
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        [segmentedControl release];
        
        [[self navigationItem] setRightBarButtonItem:segmentBarItem];
        [segmentBarItem release];
        
        // Setup the UIWebView
        UIWebView *webView = [[UIWebView alloc] init];
        [webView setDataDetectorTypes:UIDataDetectorTypeAll];
        [webView setScalesPageToFit:YES];
        [webView setDelegate:self];

        [self setWebView:webView];
        [webView release];

        // Load the page for the given address
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:address]];
        [[self webView] loadRequest:urlRequest];
        [urlRequest release];
        
        [self setView:[self webView]];
    }
    return self;
}

- (void)dealloc {
    [webView_ setDelegate:nil];
    [webView_ release];
    [super dealloc];
}


#pragma mark -
#pragma mark navigation

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
}


#pragma mark -
#pragma mark UIWebViewDelegate

// Show the network activity indicator while the page is loading
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

// Hide the network activity indicator after the page has loaded
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
