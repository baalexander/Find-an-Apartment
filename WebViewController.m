#import "WebViewController.h"


@implementation WebViewController

@synthesize webView = webView_;

- (id)init
{
    if((self = [super init]))
    {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered
                                                                    target:[self parentViewController] action:@selector(dismissModalViewController)];
        [[self navigationItem] setRightBarButtonItem:closeBtn];
        [closeBtn release];
        
        UIWebView *webView = [[UIWebView alloc] init];
        [webView setDataDetectorTypes:UIDataDetectorTypeAll];
        [webView setScalesPageToFit:YES];
        [self setWebView:webView];
        [webView release];

        [[self view] addSubview:[self webView]];
    }
    return self;
}

- (void)dealloc {
    [webView_ release];
    [super dealloc];
}


@end
