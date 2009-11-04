#import "PropertyArViewController.h"

#import "ARGeoCoordinate.h"


@implementation PropertyArViewController

- (void)awakeFromNib
{
    //[super awakeFromNib];
    [self setDebugMode:YES];
    [self setDelegate:self];
    [self setScaleViewsBasedOnDistance:YES];
    [self setMinimumScaleFactor:0.5];
    [self setRotateViewsBasedOnPerspective:YES];
    //[[self view]setBackgroundColor:[UIColor darkGrayColor]];
//    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
//    [self setCenterLocation:newCenter];
//    [newCenter release];
    
    
    
    
    
    NSMutableArray *tempLocationArray = [[NSMutableArray alloc] initWithCapacity:10];
	
	CLLocation *tempLocation;
	ARGeoCoordinate *tempCoordinate;
	
	CLLocationCoordinate2D location;
	location.latitude = 39.550051;
	location.longitude = -105.782067;
	
	tempLocation = [[CLLocation alloc] initWithCoordinate:location altitude:1609.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Denver";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:45.523875 longitude:-122.670399];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Portland";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:41.879535 longitude:-87.624333];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Chicago";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:30.268735 longitude:-97.745209];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Austin";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:51.500152 longitude:-0.126236];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"London";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:48.856667 longitude:2.350987];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Paris";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:47.620973 longitude:-122.347276];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Seattle";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:20.593684 longitude:78.96288];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/32;
	tempCoordinate.title = @"India";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:55.676294 longitude:12.568116];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Copenhagen";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:52.373801 longitude:4.890935];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Amsterdam";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:19.611544 longitude:-155.665283];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Hawaii";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:-40.900557 longitude:174.885971];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/40;
	tempCoordinate.title = @"New Zealand";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:40.756054 longitude:-73.986951];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"New York City";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:42.35892 longitude:-71.05781];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Boston";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:49.817492 longitude:15.472962];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Czech Republic";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:53.41291 longitude:-8.24389];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.inclination = M_PI/30;
	tempCoordinate.title = @"Ireland";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:45.545447 longitude:-73.639076];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Montreal";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:38.892091 longitude:-77.024055];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Washington, DC";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	tempLocation = [[CLLocation alloc] initWithLatitude:-40.900557 longitude:174.885971];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Munich";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	tempLocation = [[CLLocation alloc] initWithLatitude:32.781078 longitude:-96.797111];
	
	tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
	tempCoordinate.title = @"Dallas";
	
	[tempLocationArray addObject:tempCoordinate];
	[tempLocation release];
	
	
	[self addCoordinates:tempLocationArray];
	[tempLocationArray release];
    
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528];
	
	[self setCenterLocation:newCenter];
	[newCenter release];
	
	[self startListening];
    
    
    
    
    
    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index
{
//    DebugLog(@"ADD GEOCODED PROPERT");
//    // Adds coordinate
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[property latitude] doubleValue]
//                                                      longitude:[[property longitude] doubleValue]];
//    ARGeoCoordinate *geoCoordinate = [[ARGeoCoordinate alloc] init];
//    [geoCoordinate setGeoLocation:location];
//    [location release];
//    [geoCoordinate setTitle:[property title]];
//    
//    [self addCoordinate:geoCoordinate];
    
//    // Creates Placemark
//    Placemark *placemark = [[Placemark alloc] init];
//    [placemark setAddress:[property location]];
//    
//    // Adds coordinate
//    CLLocationCoordinate2D coordinate;
//    coordinate.longitude = [[property longitude] doubleValue];
//    coordinate.latitude = [[property latitude] doubleValue];
//    [placemark setCoordinate:coordinate];
//    
//    // Setup the pin to be placed on the map
//    PropertyAnnotation *annotation = [[PropertyAnnotation alloc] initWithPlacemark:placemark];
//    [placemark release];
//    // Index is used to keep track of button pressings on the map and the
//    // property they correspond to
//    [annotation setIndex:index];
//    
//    // Add pin to the map
//    [[self mapView] addAnnotation:annotation];
//    [annotation release];
//    
//    // If the map is not already centered, center on this property
//    if (![self isCentered])
//    {
//        [self setCentered:YES];
//        
//        [self centerOnCoordinate:coordinate];
//    }
}


#pragma mark -
#pragma mark ARViewDelegate

#define BOX_WIDTH 150
#define BOX_HEIGHT 100

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate
{	
    DebugLog(@"VIEW FOR COORDINATE");
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
