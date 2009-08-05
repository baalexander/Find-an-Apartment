#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
    @private
        UIWebView *webView_;
}

- (id)initWithAddress:(NSString *)address;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
