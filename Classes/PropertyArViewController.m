#import "PropertyArViewController.h"

#define VIEWPORT_WIDTH_RADIANS .7392
#define VIEWPORT_HEIGHT_RADIANS .5

@implementation PropertyArViewController

@synthesize propertyDataSource = propertyDataSource_;
@synthesize propertyDelegate = propertyDelegate_;
//@synthesize arkitViewController = arkitViewController_;
@synthesize imgController = imgController_;

// Start of ARProperty
@synthesize locationItems;
@synthesize locationViews;
@synthesize locationItemsInView;
@synthesize baseItems;
@synthesize propdelegate;
@synthesize gestureStartPoint;
@synthesize popupView;
@synthesize contentView;
@synthesize locationLayerView;
@synthesize selectedPoint;
@synthesize selectedSubPoint;
@synthesize contentType;
@synthesize currentRadius;
@synthesize bottomView;
@synthesize camera;
@synthesize progressView;
@synthesize updatedLocations;
@synthesize minDistance;
@synthesize shouldChangeHighlight;
@synthesize recalibrateProximity;
@synthesize currentPage;
@synthesize popupIsAdded;
// End of ARProperty

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
	//[arkitViewController_ release];
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

    PropertyArGeoCoordinate *geoCoordinate = [[PropertyArGeoCoordinate alloc] init];
	geoCoordinate = [PropertyArGeoCoordinate coordinateWithLocation:location];
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
	for(PropertyArGeoCoordinate *coord in locationItems)
	{
		// if the coordinates are nearby, add coordinate as a subset.
		if(geoAdded == false && [self isNearCoordinate:coord newCoordinate:geoCoordinate] == true)
		{
			if([coord isMultiple] != true)
			{
				[coord setIsMultiple:true];
				CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.geoLocation.coordinate.latitude
																  longitude:coord.geoLocation.coordinate.longitude];
				
				PropertyArGeoCoordinate *newGeoCoordinate = [[PropertyArGeoCoordinate alloc] init];
				newGeoCoordinate = [PropertyArGeoCoordinate coordinateWithLocation:location];
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
	
	for (PropertyArGeoCoordinate *coordinate in locationItems) {
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



// Start of ARProperty

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	popupIsAdded = false;
	
	self.updatedLocations = false;
	self.shouldChangeHighlight = true;
	self.recalibrateProximity = false;
	self.contentType = 0;
	self.minDistance = 1000.0;
	self.currentPage = 1;
    
	// re-cast contentview to UIImagePickerController
	// after that, everything should work as per normal.
	
	self.contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	
	self.locationLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[self.contentView addSubview:locationLayerView];
	
	self.contentView.backgroundColor = [UIColor clearColor];
	
	//MKCoordinateSpan span;
	//span.latitudeDelta = 0.05;
	//span.longitudeDelta = 0.05;
	CLLocationCoordinate2D theLocation;
	theLocation.latitude = self.centerLocation.coordinate.latitude;
	theLocation.longitude = self.centerLocation.coordinate.longitude;
	
	UIImageView *tabView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 427, 320, 55)];
	[tabView setImage:[UIImage imageNamed:@"arTabbar.png"]];
	[contentView addSubview:tabView];
	[tabView release];
    
	UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 440, 73, 29)];
	[btnDone setImage:[UIImage imageNamed:@"arDoneButton.png"] forState:UIControlStateNormal];
	[btnDone addTarget:self action:@selector(doneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	[self.contentView addSubview:btnDone];
	[btnDone release];
	
	self.selectedPoint = [PropertyArGeoCoordinate alloc];
	
	self.view = contentView;
	[contentView release];
}

- (void)doneClick:(id)sender {
	
	if ([self.propdelegate respondsToSelector:@selector(onARControllerClose)]) {
		[self.propdelegate onARControllerClose];
	}
	
	[self.camera dismissModalViewControllerAnimated:NO];
}

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate {
	double centerAzimuth = self.centerCoordinate.azimuth;
	double leftAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	double rightAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (rightAzimuth > 2 * M_PI) {
		rightAzimuth = rightAzimuth - 2 * M_PI;
	}
	
	BOOL result = (coordinate.azimuth > leftAzimuth && coordinate.azimuth < rightAzimuth);
	
	if(leftAzimuth > rightAzimuth) {
		result = (coordinate.azimuth < rightAzimuth || coordinate.azimuth > leftAzimuth);
	}
	
	double centerInclination = self.centerCoordinate.inclination;
	double bottomInclination = centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination = centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
    
	//check the height.
	result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination);
	
	return result;
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	if (!self.locationManager) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		
		//we want every move.
		self.locationManager.headingFilter = kCLHeadingFilterNone;
		
		[self.locationManager startUpdatingHeading];
		self.locationManager.delegate = self;
		self.locationManager.distanceFilter = 200;  // .1 miles
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[self.locationManager startUpdatingLocation];
		
	}
	
	if (!self.accelerometerManager) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = 0.04;
		self.accelerometerManager.delegate = self;
	}
	
	if (!self.centerCoordinate) {
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0];
	}
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{	
	self.centerLocation = newLocation;
	
	//MKCoordinateSpan span;
	//span.latitudeDelta = 0.01;
	//span.longitudeDelta = 0.01;
	CLLocationCoordinate2D theLocation;
	theLocation.latitude = self.centerLocation.coordinate.latitude;
	theLocation.longitude = self.centerLocation.coordinate.longitude;
	
	if(recalibrateProximity)
	{
		recalibrateProximity = false;
		[self updateProximityLocations];
	}
    
	for (PropertyArGeoCoordinate *geoLocation in self.locationItems) {
		if ([geoLocation isKindOfClass:[PropertyArGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
		}
	}
	
	[self updateLocations];
}

- (void) updateProximityLocations
{
	[locationItems release];
	locationItems = [[NSMutableArray alloc] init];
	
	for(PropertyArGeoCoordinate *geoCoordinate in baseItems)
	{
		[geoCoordinate.subLocations release];
		geoCoordinate.isMultiple = false;
		[geoCoordinate calibrateUsingOrigin:centerLocation];
		
		if(geoCoordinate.radialDistance < self.minDistance)
		{
			self.minDistance = geoCoordinate.radialDistance;
		}
		
		NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[locationItems count] + 1];
		
		bool geoAdded = false;
		for(PropertyArGeoCoordinate *coord in locationItems)
		{
			// if the coordinates are nearby, add coordinate as a subset.
			if(geoAdded == false && [self isNearCoordinate:coord newCoordinate:geoCoordinate] == true)
			{
				if([coord isMultiple] != true)
				{
					[coord setIsMultiple:true];
					CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.geoLocation.coordinate.latitude
																	  longitude:coord.geoLocation.coordinate.longitude];
					
					PropertyArGeoCoordinate *newGeoCoordinate = [[PropertyArGeoCoordinate alloc] init];
					newGeoCoordinate = [PropertyArGeoCoordinate coordinateWithLocation:location];
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
		
		for (PropertyArGeoCoordinate *coordinate in locationItems) {
			//create the views here.
			
			//call out for the delegate's view.
			if ([self.propdelegate respondsToSelector:@selector(viewForCoordinate:)]) {
				[newTempArray addObject:[self.propdelegate viewForCoordinate:coordinate]];
			}
		}
		
		self.locationViews = newTempArray;
		
		
		self.updatedLocations = true;
	}
}

- (bool)isNearCoordinate:(PropertyArGeoCoordinate *)coord newCoordinate:(PropertyArGeoCoordinate *)newCoord
{
	bool isNear = true;
	float baseRange = .0015;
	float range = baseRange * coord.radialDistance;
	
	if((newCoord.geoLocation.coordinate.latitude > (coord.geoLocation.coordinate.latitude + range)) ||
	   (newCoord.geoLocation.coordinate.latitude < (coord.geoLocation.coordinate.latitude - range)))
	{
		isNear = false;
	}
	if((newCoord.geoLocation.coordinate.longitude > (coord.geoLocation.coordinate.longitude + range)) ||
	   (newCoord.geoLocation.coordinate.longitude < (coord.geoLocation.coordinate.longitude - range)))
	{
		isNear = false;
	}
	
	return isNear;
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	
	double pointAzimuth = coordinate.azimuth;
	
	//our x numbers are left based.
	double leftAzimuth = self.centerCoordinate.azimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	if (pointAzimuth < leftAzimuth) {
		//it's past the 0 point.
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.height;
	} else {
		
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.height;
	}
	
	//y coordinate.
	
	double pointInclination = coordinate.inclination;
	double topInclination = self.centerCoordinate.inclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	// changing from width to height on the reality frame to account for portrait.
	point.y = realityView.frame.size.height - ((pointInclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * realityView.frame.size.height;
	
	return point;
}

#define kFilteringFactor 0.05
UIAccelerationValue rollingX, rollingZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// -1 face down.
	// 1 face up.
	
	//update the center coordinate.
	
	// trying to reverse it here.. changed x to acceleration.y..
	
	rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
	if (rollingX > 0.0) {
		self.centerCoordinate.inclination =  - atan(rollingZ / rollingX) - M_PI;
	} else if (rollingX < 0.0) {
		self.centerCoordinate.inclination = - atan(rollingZ / rollingX);// + M_PI;
	} else if (rollingZ < 0) {
		self.centerCoordinate.inclination = M_PI/2.0;
	} else if (rollingZ >= 0) {
		self.centerCoordinate.inclination = 3 * M_PI/2.0;
	}
    
	[self updateLocations];
}

NSComparisonResult LocationSortFarthesttFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedAscending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (void)updateLocations {
	
	if(self.baseItems.count < 25 && progressView == nil)
	{
		progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 320, 480)];
		[progressView startAnimating];
		progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[progressView sizeToFit];
		
		[self.view addSubview:progressView];
		
	}
	else if(self.baseItems.count >= 25)
	{
		[progressView removeFromSuperview];
	}
	
	unsigned int index = 0;
	
	for (PropertyArGeoCoordinate *item in self.locationItems) 
	{
		UIImageView *viewToDraw = [self.locationViews objectAtIndex:index];
		
		NSString *theImage = @"arPropertyButton.png";
		if(self.selectedPoint != nil)
		{
			if(item.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
			   item.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude)
			{
				theImage = @"arSelectedPropertyButton.png";
				
				if(item.isMultiple)
					theImage = @"arSelectedPropertiesButton.png";
			}
			else 
			{
				if(item.isMultiple)
				{
					theImage = @"arPropertiesButton.png";
					
					for(PropertyArGeoCoordinate *coord in item.subLocations)
					{
						if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
						   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude)
						{
							theImage = @"arSelectedPropertiesButton.png";
						}
					}
				}
			}
		}
		
		int tag = 0;
		
		if(item.isMultiple)
			tag = 1;
        
		UIImage *img = [UIImage imageNamed:theImage];
		[viewToDraw setImage:img];
		[viewToDraw setTag:tag];
		
		if ([self viewportContainsCoordinate:item]) {
			CGPoint loc = [self pointInView:self.view forCoordinate:item];
			
			float width = viewToDraw.frame.size.width;
			float height = viewToDraw.frame.size.height;
			
			viewToDraw.frame = CGRectMake(loc.x - width / 2.0, loc.y - width / 2.0, width, height);
			
			[self.locationLayerView addSubview:viewToDraw];
			
			
		} else {
			
			[viewToDraw removeFromSuperview];
		}
		
		index++;
	}
	
	[self.locationItemsInView release];
	self.locationItemsInView = [[NSMutableArray alloc] init];
}

#define BOX_WIDTH 200
#define BOX_HEIGHT 68

- (UIView *)viewForCoordinate:(PropertyArGeoCoordinate *)coordinate {
	
	[coordinate calibrateUsingOrigin: self.centerLocation];
	
	double inclinationFactor = 33 * coordinate.radialDistance;
	
	if(coordinate.radialDistance < .5)
	{
		inclinationFactor = 27;
	}
	
	coordinate.inclination = -M_PI/inclinationFactor + .05;
	
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	NSString *theImage = @"arFinalPoint.png";
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:theImage]];
	imgView.frame = theFrame;
	imgView.alpha = .85;
	[imgView setUserInteractionEnabled:TRUE];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 11, BOX_WIDTH - 10, 20.0)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font =[UIFont fontWithName:@"Helvetica" size: 18];
	titleLabel.shadowColor = [UIColor grayColor];
	titleLabel.shadowOffset = CGSizeMake(1, 1);
	titleLabel.text = coordinate.title;
	//[titleLabel sizeToFit];
	
	UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 27, BOX_WIDTH - 10, 20.0)];
	distanceLabel.backgroundColor = [UIColor clearColor];
	distanceLabel.textColor = [UIColor whiteColor];
	distanceLabel.font =[UIFont fontWithName:@"Helvetica" size: 16];
	distanceLabel.shadowColor = [UIColor grayColor];
	distanceLabel.shadowOffset = CGSizeMake(1, 1);
	distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", coordinate.radialDistance];
	
	[imgView addSubview:titleLabel];
	[imgView addSubview:distanceLabel];
	
	return [imgView autorelease];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {	
	// former: add 90 to trueHeading
	self.centerCoordinate.azimuth = fmod(newHeading.trueHeading, 360.0) * (2 * (M_PI / 360.0));
	[self updateLocations];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	gestureStartPoint = [touch locationInView:self.view];
    
	if(self.locationViews != nil)
	{
        int index = 0;
        for(UIView *item in self.locationViews)
        {
            if([touch view] == item)
            {
                //if(self.locationItems.count >= index)
                //{
                self.currentPage = 1;
                [self.selectedPoint release];
                self.selectedPoint = [PropertyArGeoCoordinate alloc];
                self.selectedPoint = (PropertyArGeoCoordinate *)[self.locationItems objectAtIndex:index];
                
                [self makePanel];
                
                [UIView beginAnimations: nil context: @"some-identifier-used-by-a-delegate-if-set"];
                [UIView setAnimationDelegate: self];
                [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration: 0.4f];
                
                double topPoint = 210.0f;
                
                if(contentType == 2)
                    topPoint = 130.0f;
                else if(contentType == 1)
                    topPoint = 171.0f;
                
                CGRect tempFrame = popupView.frame;
                tempFrame.origin.y = topPoint;
                self.popupView.frame = tempFrame;
                
                popupIsAdded = true;
                [UIView commitAnimations];
            }
            
            index++;
        }
	}
	
}

- (void)getNextPanel {
	
	int index = 0;
	int currentIndex = 0;
	
	for(PropertyArGeoCoordinate *coord in self.selectedPoint.subLocations)
	{
		if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
		   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude
		   && coord.title == self.selectedPoint.title)
		{
			currentIndex = index + 1;
		}
		
		index++;
	}
	
	self.currentPage++;
	if(currentIndex > index - 1)
	{
		self.currentPage = 1;
		currentIndex = 0;
	}
	
	NSMutableArray *subLocations = [[NSMutableArray	alloc] init];
	subLocations = self.selectedPoint.subLocations;
    
	
	self.selectedPoint = [PropertyArGeoCoordinate alloc];
	self.selectedPoint = (PropertyArGeoCoordinate *)[subLocations objectAtIndex:currentIndex];
	self.selectedPoint.subLocations = subLocations;
	[self.selectedPoint calibrateUsingOrigin: self.centerLocation];
	
	shouldChangeHighlight = false;
	
	
	[self makePanel];
}

- (void)getPrevPanel {
	int index = 0;
	int currentIndex = 0;
	
	for(PropertyArGeoCoordinate *coord in self.selectedPoint.subLocations)
	{
		if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
		   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude
           && coord.title == self.selectedPoint.title)
		{
			currentIndex = index - 1;
		}
		
		index++;
	}
	
	self.currentPage--;
	if(currentIndex < 0)
	{
		self.currentPage = index;
		currentIndex = index - 1;
	}
	
	NSMutableArray *subLocations = [[NSMutableArray	alloc] init];
	subLocations = self.selectedPoint.subLocations;
	
	
	self.selectedPoint = [PropertyArGeoCoordinate alloc];
	self.selectedPoint = (PropertyArGeoCoordinate *)[subLocations objectAtIndex:currentIndex];
	self.selectedPoint.subLocations = subLocations;
	[self.selectedPoint calibrateUsingOrigin: self.centerLocation];
	
	shouldChangeHighlight = false;
	
	[self makePanel];
}

- (void)makePanel 
{	
	if(popupIsAdded)
	{
		if(self.popupView != nil)
		{
			[self.popupView removeFromSuperview];
			[self.popupView release];
		}
	}
	
	int topPoint = 500;
	
	if(popupIsAdded)
		topPoint = 210;
	
	self.popupView = [[UIView alloc] initWithFrame:CGRectMake(14, topPoint, 292, 215)];
    
	[self.view addSubview:self.popupView];
	popupIsAdded = true;
	
	int buttonStart = 19;
	
	UIImageView *theImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 292, 215)];
	[theImgView setImage:[UIImage imageNamed:@"arPopupBackground.png"]];
	[self.popupView addSubview:theImgView];
	
	UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(19, 10, 270, 26)];
	titleText.text = self.selectedPoint.title;
	titleText.shadowColor = [UIColor grayColor];
	titleText.shadowOffset = CGSizeMake(1, 1);
	titleText.font =[UIFont fontWithName:@"Helvetica" size: 20];
	titleText.textColor = [UIColor whiteColor];
	titleText.backgroundColor = [UIColor clearColor];
    
	[self.popupView addSubview:titleText];
	[titleText release];
    
	UILabel *distanceText = [[UILabel alloc] initWithFrame:CGRectMake(19, 32, 270, 20)];
	distanceText.text = [NSString stringWithFormat:@"%.1f miles", self.selectedPoint.radialDistance];
	distanceText.font = [UIFont fontWithName:@"Helvetica" size: 16];
	distanceText.textColor = [UIColor whiteColor];
	distanceText.backgroundColor = [UIColor clearColor];
    
	[self.popupView addSubview:distanceText];
	[distanceText release];
    
	UILabel *subtitleText = [[UILabel alloc] initWithFrame:CGRectMake(19, 65, 270, 18)];
	subtitleText.text = self.selectedPoint.subtitle;
	subtitleText.font = [UIFont fontWithName:@"Helvetica" size: 16];
	subtitleText.textColor = [UIColor whiteColor];
	subtitleText.backgroundColor = [UIColor clearColor];
    
	if(self.selectedPoint.subtitle != nil)
	{
		[self.popupView addSubview:subtitleText];
	}
	[subtitleText release];
	
	UILabel *summaryText = [[UILabel alloc] initWithFrame:CGRectMake(19, 85, 270, 18)];
	summaryText.text = [NSString stringWithFormat:@"%@", self.selectedPoint.summary];
	summaryText.font = [UIFont fontWithName:@"Helvetica" size: 16];
	summaryText.textColor = [UIColor whiteColor];
	summaryText.backgroundColor = [UIColor clearColor];
    
	if(self.selectedPoint.summary != nil)
	{
		[self.popupView addSubview:summaryText];
	}
	[summaryText release];
	
	UILabel *priceText = [[UILabel alloc] initWithFrame:CGRectMake(19, 105, 270, 18)];
	priceText.text = [NSString stringWithFormat:@"$%@", self.selectedPoint.price];
	priceText.font = [UIFont fontWithName:@"Helvetica" size: 16];
	priceText.textColor = [UIColor whiteColor];
	priceText.backgroundColor = [UIColor clearColor];
    
	if(self.selectedPoint.price != nil)
	{
		[self.popupView addSubview:priceText];
	}
	[priceText release];
	
	UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(-5, -5, 30, 28)];
	[btnClose setImage:[UIImage imageNamed:@"arPopupCloseButton.png"] forState:UIControlStateNormal];
	[btnClose addTarget:self action:@selector(panelCloseClick:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
	
	[self.popupView addSubview:btnClose];
	[btnClose release];
    
	// to pop the details view.
	
	UIButton *detailsButton = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] initWithFrame:CGRectMake(250, 10, 30, 28)];
	
	// figure out the tag for the details button
	int theTag = 0;
	int x = 0;
	for(PropertyArGeoCoordinate *baseCoord in self.baseItems)
	{
		if(baseCoord.title == self.selectedPoint.title &&
		   baseCoord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude &&
		   baseCoord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude)
		{
			theTag = x;
		}
        
		x++;
	}
	
	[detailsButton setTag:theTag];
	[detailsButton addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
    
	[self.popupView addSubview:detailsButton];
	
	if(self.locationItems.count > 1)
		buttonStart = 55;
    
	UIButton *btnCall = [[UIButton alloc] initWithFrame:CGRectMake(buttonStart, 143, 59, 62)];
	[btnCall setImage:[UIImage imageNamed:@"Phone2.png"] forState:UIControlStateNormal];
	[btnCall addTarget:self action:@selector(callClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
    
	[self.popupView addSubview:btnCall];
	[btnCall release];
    
	buttonStart += 59;
    
	UIButton *btnMaps = [[UIButton alloc] initWithFrame:CGRectMake(buttonStart, 143, 59, 62)];
	[btnMaps setImage:[UIImage imageNamed:@"Maps2.png"] forState:UIControlStateNormal];
	[btnMaps addTarget:self action:@selector(mapsClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
    
	[self.popupView addSubview:btnMaps];
	[btnMaps release];
    
	buttonStart += 61;
    
	UIButton *btnBing = [[UIButton alloc] initWithFrame:CGRectMake(buttonStart, 145, 59, 62)];
	[btnBing setImage:[UIImage imageNamed:@"Bing2.png"] forState:UIControlStateNormal];
	[btnBing addTarget:self action:@selector(bingClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
    
	[self.popupView addSubview:btnBing];
	[btnBing release];
    
	if(self.selectedPoint.subLocations.count > 1)
	{
		buttonStart += 73;
        
		UIButton *btnNextArrow = [[UIButton alloc] initWithFrame:CGRectMake(buttonStart, 143, 50, 62)];
		[btnNextArrow setImage:[UIImage imageNamed:@"arNext.png"] forState:UIControlStateNormal];
		[btnNextArrow addTarget:self action:@selector(nextClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
        
		[self.popupView addSubview:btnNextArrow];
		[btnNextArrow release];
		
		buttonStart = buttonStart - 125;
		UILabel *lblPageNotification = [[UILabel alloc] initWithFrame:CGRectMake(buttonStart, 149, 100, 62)];
		lblPageNotification.text = [NSString stringWithFormat:@"%d of %d",self.currentPage, self.selectedPoint.subLocations.count];
		lblPageNotification.font = [UIFont fontWithName:@"Helvetica" size: 16];
		lblPageNotification.textColor = [UIColor whiteColor];
		lblPageNotification.backgroundColor = [UIColor clearColor];
		
		[self.popupView addSubview:lblPageNotification];
		[lblPageNotification release];
		
		UIButton *btnPrevArrow = [[UIButton alloc] initWithFrame:CGRectMake(-8, 143, 50, 62)];
		[btnPrevArrow setImage:[UIImage imageNamed:@"arPrevious.png"] forState:UIControlStateNormal];
		[btnPrevArrow addTarget:self action:@selector(prevClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
        
		[self.popupView addSubview:btnPrevArrow];
		[btnPrevArrow release];
	}
}

- (void)panelCloseClick:(id)sender {
	[UIView beginAnimations: nil context: @"some-identifier-used-by-a-delegate-if-set"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = popupView.frame;
	tempFrame.origin.y = 500.0f;
	self.popupView.frame = tempFrame;
	
	[UIView commitAnimations];
	
	[self.selectedPoint release];
	self.selectedPoint = [PropertyArGeoCoordinate alloc];
	
	for(UIImageView *imgView in self.locationViews)
	{
		if(imgView.tag == 1)
			[imgView setImage:[UIImage imageNamed:@"apts"]];
		else if(imgView.tag == 2)
			[imgView setImage:[UIImage imageNamed:@"apt"]];
	}
	
	popupIsAdded = false;
}

- (void)nextClick:(id)sender {
	[self getNextPanel];
}

- (void)prevClick:(id)sender {
	[self getPrevPanel];
} 

- (void)setCenterLocation:(CLLocation *)newLocation {
	[centerLocation release];
	centerLocation = [newLocation retain];
	
	for (PropertyArGeoCoordinate *geoLocation in self.locationItems) {
		if ([geoLocation isKindOfClass:[PropertyArGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
		}
	}
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
