#import "PropertyImageViewController.h"


@implementation PropertyImageViewController

@synthesize images = images_;

- (id)initWithImages:(NSArray *)images
{
    if((self = [super init]))
    {
        [self setImages:images];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark TTPhotoSource methods

- (id<TTPhoto>)photoAtIndex:(NSInteger)index
{    
//    id<TTPhoto> photo = [[TTPhoto alloc] initWith
    return nil;
}

@end
