#import <Three20/Three20.h>


@interface ImageSource : TTURLRequestModel <TTPhotoSource>
{
    @private
        NSString *title_;
        NSMutableArray *images_;
        NSArray *tempImages_;
        NSTimer *loadTimer_;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSMutableArray *images;

- (id)initWithTitle:(NSString *)title withImages:(NSArray *)images;

@end
