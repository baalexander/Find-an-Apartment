#import "ImageSource.h"


@interface ImageSource ()
@property (nonatomic, retain) NSArray *tempImages;
@property (nonatomic, retain) NSTimer *loadTimer;
@end


@implementation ImageSource

@synthesize title = title_;
@synthesize images = images_;
@synthesize tempImages = tempImages_;
@synthesize loadTimer = loadTimer_;


- (id)initWithTitle:(NSString*)title withImages:(NSArray *)images
{
    if ((self = [super init]))
    {
        [self setTitle:title];
        [self setTempImages:images];
        
        NSMutableArray *loadedImages = [[NSMutableArray alloc] init];
        [self setImages:loadedImages];
        [loadedImages release];
        
        [self performSelector:@selector(loadReady)];
    }
    
    return self;
}

- (void)dealloc
{
    [title_ release];
    [tempImages_ release];
    [images_ release];
    [loadTimer_ release];

    [super dealloc];
}

- (void)loadReady
{
    [self setLoadTimer:nil];
    
    NSMutableArray *newImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (NSInteger)[[self images] count]; i++)
    {
        id<TTPhoto> image = [[self images] objectAtIndex:i];
        if ((NSNull*)image != [NSNull null])
        {
            [newImages addObject:image];
        }
    }
    
    [newImages addObjectsFromArray:[self tempImages]];
    [self setTempImages:nil];
  
    [self setImages:newImages];
    [newImages release];
    
    for (int i = 0; i < (NSInteger)[[self images] count]; i++)
    {
        id<TTPhoto> image = [[self images] objectAtIndex:i];
        if ((NSNull*)image != [NSNull null])
        {
            [image setPhotoSource:self];
            [image setIndex:i];
        }
    }
    
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


#pragma mark -
#pragma mark TTModel

- (BOOL)isLoading
{
    return !![self loadTimer];
}

- (BOOL)isLoaded
{
    return !![self images];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
    if (cachePolicy & TTURLRequestCachePolicyNetwork)
    {
        [_delegates perform:@selector(modelDidStartLoad:) withObject:self];

        [self setImages:nil];
        [self setLoadTimer:[NSTimer scheduledTimerWithTimeInterval:2
                                                            target:self
                                                          selector:@selector(loadReady)
                                                          userInfo:nil
                                                           repeats:NO]];
    }
}

- (void)cancel
{
    [[self loadTimer] invalidate];
    [self setLoadTimer:nil];
}


#pragma mark -
#pragma mark TTPhotoSource

- (NSInteger)numberOfPhotos
{
    return [[self images] count];
}

- (NSInteger)maxPhotoIndex
{
    return [self numberOfPhotos] - 1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index
{
    if (index <= [self maxPhotoIndex])
    {
        return [[self images] objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

@end
