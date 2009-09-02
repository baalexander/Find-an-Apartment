#import "ImagesViewController.h"

#import "ImageSource.h"
#import "Image.h"


@implementation ImagesViewController


#pragma mark -
#pragma mark ImagesViewController

- (id)initWithUrls:(NSArray *)urls
{
    if ((self = [super init]))
    {
        //Increases the max allowed image size in bytes
        [[TTURLRequestQueue mainQueue] setMaxContentLength:750000];
        
        //Sets the default image to a placeholder image if it exists
        UIImage *defaultImage = [UIImage imageNamed:@"imageLoading.png"];
        if (defaultImage != nil)
        {
            [self setDefaultImage:defaultImage];
        }

        // Configure the in-memory image cache to keep approximately
        // 5 images in memory, assuming that each picture's dimensions
        // are 320x480. Note that your images can have whatever dimensions
        // you want, I am just setting this to a reasonable value
        // since the default is unlimited.
        [[TTURLCache sharedCache] setMaxPixelCount:5 * 320 * 480];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSURL *url in urls)
        {
            Image *image = [[Image alloc] initWithUrl:url];
            [images addObject:image];
            [image release];
        }
        
        ImageSource *imageSource = [[ImageSource alloc] initWithTitle:@"Images" withImages:images];
        [images release];
        [self setPhotoSource:imageSource];
        [imageSource release];        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
