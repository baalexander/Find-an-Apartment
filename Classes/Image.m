#import "Image.h"


@interface Image ()
@property (nonatomic, copy) NSString *url;
@end


@implementation Image

@synthesize url = url_;
@synthesize photoSource = photoSource_;
@synthesize size = size_;
@synthesize index = index_;
@synthesize caption = caption_;

- (id)initWithUrl:(NSURL *)url
{
    if ((self = [super init]))
    {
        [self setUrl:[url description]];

        //TTPhoto values
        //Use CGSizeZero unless the image size is known
        [self setSize:CGSizeZero];
        [self setPhotoSource:nil];
        [self setCaption:nil];
        [self setIndex:NSIntegerMax];
    }
    
    return self;
}

- (void)dealloc
{
    [url_ release];

    [super dealloc];
}


#pragma mark -
#pragma mark TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version
{
    if (version == TTPhotoVersionLarge)
    {
        return [self url];
    }
    else if (version == TTPhotoVersionMedium)
    {
        return [self url];
    }
    else if (version == TTPhotoVersionSmall)
    {
        return [self url];
    }
    else if (version == TTPhotoVersionThumbnail)
    {
        return [self url];
    }
    else
    {
        return nil;
    }
}

@end
