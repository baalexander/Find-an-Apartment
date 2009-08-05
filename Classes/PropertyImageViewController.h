#import <UIKit/UIKit.h>

#import "Three20/Three20.h"


@interface PropertyImageViewController : TTPhotoViewController
{
    @private
        NSArray *images_;
}

@property (nonatomic, retain) NSArray *images;

- (id)initWithImages:(NSArray *)images;

@end
