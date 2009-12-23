#import "PropertyArViewController.h"

#import "ARGeoCoordinate.h"


@implementation PropertyArViewController

@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyDelegate = propertyDelegate_;
@synthesize arkitViewController = arkitViewController_;
@synthesize imgController;


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
		
		//CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:45.529651 longitude:-122.683039];
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

    ARGeoCoordinate *geoCoordinate = [[ARGeoCoordinate alloc] init];
	geoCoordinate = [ARGeoCoordinate coordinateWithLocation:location];
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
		NSLog(@"distance: %.8f", geoCoordinate.radialDistance);
	}
	
	if(self.baseItems == nil)
		self.baseItems = [[NSMutableArray alloc] init];
	
	[self.baseItems addObject:geoCoordinate];
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[locationItems count] + 1];
	
	bool geoAdded = false;
	for(ARGeoCoordinate *coord in locationItems)
	{
		// if the coordinates are nearby, add coordinate as a subset.
		if(geoAdded == false && [self isNearCoordinate:coord newCoordinate:geoCoordinate] == true)
		{
			if([coord isMultiple] != true)
			{
				[coord setIsMultiple:true];
				CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.geoLocation.coordinate.latitude
																  longitude:coord.geoLocation.coordinate.longitude];
				
				ARGeoCoordinate *newGeoCoordinate = [[ARGeoCoordinate alloc] init];
				newGeoCoordinate = [ARGeoCoordinate coordinateWithLocation:location];
				[newGeoCoordinate setTitle:[coord title]];
				[newGeoCoordinate setIsMultiple:false];
				[location release];
				
				coord.subLocations = [[NSMutableArray alloc] init];
				
				[[coord subLocations] addObject:newGeoCoordinate];
			}
		
			[[coord subLocations] addObject:geoCoordinate];
			[tempArray addObject:coord];
			geoAdded = true;
			
			//NSLog(@"is near.. old: %@  new: %@", coord.title, geoCoordinate.title);
		}
		else
		{
			if(coord.geoLocation.coordinate.latitude != geoCoordinate.geoLocation.coordinate.latitude &&
			   coord.geoLocation.coordinate.longitude != geoCoordinate.geoLocation.coordinate.longitude)
			{
				[tempArray addObject:coord];
			}
		}
		
		//NSLog(@"coord title: %@ count: %d", coord.title, coord.subLocations.count);
	}
	
	if(geoAdded == false)
	{
		[tempArray addObject:geoCoordinate];
	}
	
	[locationItems release];
	locationItems = [tempArray retain];
	
	//NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:tempArray];
	//[sortedArray sortUsingFunction:LocationSortClosestFirst context:NULL];
	
	//locationItems = [sortedArray copy];
	
	for (UIView *view in self.locationLayerView.subviews) {
		[view removeFromSuperview];
	}
	
	NSMutableArray *newTempArray = [NSMutableArray array];
	
	for (ARGeoCoordinate *coordinate in locationItems) {
		//create the views here.
		
		//call out for the delegate's view.
		if ([self.delegate respondsToSelector:@selector(viewForCoordinate:)]) {
			[newTempArray addObject:[self.delegate viewForCoordinate:coordinate]];
		}
	}
	
	self.locationViews = newTempArray;
		 
	
	self.updatedLocations = true;
	
	//[tempArray release];
	//[geoCoordinate release];
	//[location release];
	
	
	//NSLog(@"%@ lat: %.8f, long: %.8f", property.title, geoCoordinate.geoLocation.coordinate.latitude, geoCoordinate.geoLocation.coordinate.longitude);
	//NSLog(@"center location: lat: %.8f, long: %.8f", self.centerLocation.coordinate.latitude, self.centerLocation.coordinate.longitude);
	
	//[self setLocationItems:tempLocationArray];
	
	//[tempLocationArray release];
	
	//[self addLocationItem:geoCoordinate];
	
	
    // TODO: Include index so can identify property clicked
    //[self addCoordinate:geoCoordinate];
}

@end
