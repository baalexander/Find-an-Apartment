#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
    @private
        UIWebView *webView_;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
