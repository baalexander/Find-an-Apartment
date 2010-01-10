#import "PropertyArViewController.h"


@implementation PropertyArViewController

@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyDelegate = propertyDelegate_;
@synthesize arkitViewController = arkitViewController_;
@synthesize imgController = imgController_;


- (id)init
{
    if ((self = [super init]))
    {
		/*
        [self setDebugMode:YES];
        [self setDelegate:self];
        [self setScaleViewsBasedOnDistance:YES];
        [self setMinimumScaleFactor:0.5];
        [self setRotateViewsBasedOnPerspective:YES];
        */
		
		CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:0 longitude:0];
		
		self.centerLocation = newCenter;
		[newCenter release];
    }
    
    return self;
}

- (void)dealloc
{
	[arkitViewController_ release];
    [super dealloc];
}

- (IBAction)clickedButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [[self propertyDelegate] view:[self view] didSelectPropertyAtIndex:[button tag]];
	
	
	[self.camera dismissModalViewControllerAnimated:YES];
}

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index
{
	self.recalibrateProximity = true;
    // Adds coordinate
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[property latitude] doubleValue]
                                                      longitude:[[property longitude] doubleValue]];

    PropertyARGeoCoordinate *geoCoordinate = [[PropertyARGeoCoordinate alloc] init];
	geoCoordinate = [PropertyARGeoCoordinate coordinateWithLocation:location];
    [geoCoordinate setTitle:[property title]];
	[geoCoordinate setSubtitle:[property subtitle]];
	[geoCoordinate setSummary:[property summary]];
	[geoCoordinate setPrice:[[property price] description]];
	[geoCoordinate setIsMultiple:false];
	[geoCoordinate setViewSet:false];
    [location release];
	
	[geoCoordinate calibrateUsingOrigin: self.centerLocation];
	
	if(geoCoordinate.radialDistance < self.minDistance)
	{
		self.minDistance = geoCoordinate.radialDistance;
	}
	
	if(self.baseItems == nil)
		self.baseItems = [[NSMutableArray alloc] init];
	
	[self.baseItems addObject:geoCoordinate];
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[locationItems count] + 1];
	
	bool geoAdded = false;
	for(PropertyARGeoCoordinate *coord in locationItems)
	{
		// if the coordinates are nearby, add coordinate as a subset.
		if(geoAdded == false && [self isNearCoordinate:coord newCoordinate:geoCoordinate] == true)
		{
			if([coord isMultiple] != true)
			{
				[coord setIsMultiple:true];
				CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.geoLocation.coordinate.latitude
																  longitude:coord.geoLocation.coordinate.longitude];
				
				PropertyARGeoCoordinate *newGeoCoordinate = [[PropertyARGeoCoordinate alloc] init];
				newGeoCoordinate = [PropertyARGeoCoordinate coordinateWithLocation:location];
				[newGeoCoordinate setTitle:[coord title]];
				[newGeoCoordinate setIsMultiple:false];
				[location release];
				
				coord.subLocations = [[NSMutableArray alloc] init];
				
				[[coord subLocations] addObject:newGeoCoordinate];
			}
		
			[[coord subLocations] addObject:geoCoordinate];
			[tempArray addObject:coord];
			geoAdded = true;
		}
		else
		{
			if(coord.geoLocation.coordinate.latitude != geoCoordinate.geoLocation.coordinate.latitude &&
			   coord.geoLocation.coordinate.longitude != geoCoordinate.geoLocation.coordinate.longitude)
			{
				[tempArray addObject:coord];
			}
		}
	}
	
	if(geoAdded == false)
	{
		[tempArray addObject:geoCoordinate];
	}
	
	[locationItems release];
	locationItems = [tempArray retain];
	
	for (UIView *view in self.locationLayerView.subviews) {
		[view removeFromSuperview];
	}
	
	NSMutableArray *newTempArray = [NSMutableArray array];
	
	for (PropertyARGeoCoordinate *coordinate in locationItems) {
		//create the views here.
		
		//call out for the delegate's view.
		if ([self.propdelegate respondsToSelector:@selector(viewForCoordinate:)]) {
			[newTempArray addObject:[self.propdelegate viewForCoordinate:coordinate]];
		}
	}
	
	self.locationViews = newTempArray;
		 
	self.updatedLocations = true;
		
    // TODO: Include index so can identify property clicked
    //[self addCoordinate:geoCoordinate];
}

@end
