#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface PropertyListEmailerViewController : MFMailComposeViewController
{
    @private
        NSArray *properties_;
}

@property (nonatomic, retain) NSArray *properties;

@end
