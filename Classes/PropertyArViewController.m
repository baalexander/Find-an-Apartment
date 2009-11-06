#import "PropertyArViewController.h"

#import "ARGeoCoordinate.h"


@implementation PropertyArViewController

@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyDelegate = propertyDelegate_;


- (id)init
{
    if ((self = [super init]))
    {
        [self setDebugMode:YES];
        [self setDelegate:self];
        [self setScaleViewsBasedOnDistance:YES];
        [self setMinimumScaleFactor:0.5];
        [self setRotateViewsBasedOnPerspective:YES];
        
        CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
        [self setCenterLocation:newCenter];
        [newCenter release];
        
        [self startListening];        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)clickedButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [[self propertyDelegate] view:[self view] didSelectPropertyAtIndex:[button tag]];
}

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index
{
    // Adds coordinate
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[property latitude] doubleValue]
                                                      longitude:[[property longitude] doubleValue]];

    ARGeoCoordinate *geoCoordinate = [[ARGeoCoordinate alloc] init];
    [geoCoordinate setGeoLocation:location];
    [location release];
    [geoCoordinate setTitle:[property title]];
    
    // TODO: Include index so can identify property clicked
    [self addCoordinate:geoCoordinate];
}


#pragma mark -
#pragma mark ARViewDelegate

#define BOX_WIDTH 150
#define BOX_HEIGHT 100

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate
{
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	UIView *tempView = [[UIView alloc] initWithFrame:theFrame];
	
	//tempView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.3];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
	titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = coordinate.title;
	[titleLabel sizeToFit];
	
	titleLabel.frame = CGRectMake(BOX_WIDTH / 2.0 - titleLabel.frame.size.width / 2.0 - 4.0, 0, titleLabel.frame.size.width + 8.0, titleLabel.frame.size.height + 8.0);
	
	UIImageView *pointView = [[UIImageView alloc] initWithFrame:CGRectZero];
	pointView.image = [UIImage imageNamed:@"locate.png"];
	pointView.frame = CGRectMake((int)(BOX_WIDTH / 2.0 - pointView.image.size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - pointView.image.size.height / 2.0), pointView.image.size.width, pointView.image.size.height);
    
	[tempView addSubview:titleLabel];
	[tempView addSubview:pointView];
	
	[titleLabel release];
	[pointView release];
	
	return [tempView autorelease];
}

@end
