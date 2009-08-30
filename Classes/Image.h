#import <Three20/Three20.h>

@interface Image : NSObject <TTPhoto>
{
    id<TTPhotoSource> photoSource_;
    NSString *url_;
    CGSize size_;
    NSInteger index_;
    NSString *caption_;
}

- (id)initWithUrl:(NSURL *)url;

@end
