#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate>
{
    @private
        UIWebView *webView_;
        NSURL *url_;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURL *url;

@end
