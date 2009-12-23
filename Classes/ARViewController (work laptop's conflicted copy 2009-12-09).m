//
//  ARKViewController.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Gravity Mobile. All rights reserved.
//

#import "ARViewController.h"
#import "AddressAnnotation.h"
//#import "asyncimageview.h"

#define VIEWPORT_WIDTH_RADIANS .7392
#define VIEWPORT_HEIGHT_RADIANS .5

@implementation ARViewController

@synthesize locationManager, accelerometerManager;
@synthesize centerCoordinate, locationItems, locationViews, locationItemsInView, baseItems;

@synthesize delegate;

//@synthesize mapView;

@synthesize centerLocation;
@synthesize popupView, contentView, locationLayerView;
@synthesize gestureStartPoint;
@synthesize selectedPoint, selectedSubPoint;
@synthesize contentType, currentRadius;
@synthesize btnContentBing, btnContentTwitter, btnContentFlickr, btnContentKml, btnContentWiki;
@synthesize btnCategoryPicker;
@synthesize categoryView;
@synthesize bottomView;
@synthesize btnSettings;
@synthesize myMapsTable, myMapsList;
@synthesize camera;
@synthesize progressView;

@synthesize webView;
@synthesize updatedLocations;
@synthesize minDistance;
@synthesize shouldChangeHighlight, recalibrateProximity;

bool popupIsAdded = false;
bool photoIsAdded = false;
bool isInitialQuery = true;
bool shouldResetMapView = true;
int lastRowCount = 0;
MKCoordinateRegion region;
NSString *currentBingQuery;
NSMutableArray *theCategories;
NSMutableArray *theRadius;

// for big pictures. :)
UIImageView *ivc;
UIButton *btnDone, *btnAdd;

NSString *currentSelectedCategory;

int pickerType = 0;

int radiusSelectedIndex = 2;
NSString *currentSelectedRadius;

// 0 == phone
// 1 == directions
// 2 == bing
// 3 == tweets
// 4 == flickr
int alertType = 0;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// this is how i tell the difference between bing, twitter etc for content.
	// bing == 0;
	// twitter == 1;
	// flickr == 2;
	self.updatedLocations = false;
	self.shouldChangeHighlight = true;
	self.recalibrateProximity = false;
	self.contentType = 0;
	self.minDistance = 1000.0;
	
	// defaults to 3 miles.
	currentRadius = @"3";
	
	// re-cast contentview to UIImagePickerController
	// after that, everything should work as per normal.
	
	self.contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	
	self.locationLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[self.contentView addSubview:locationLayerView];
	
	self.contentView.backgroundColor = [UIColor clearColor];
	
	//self.mapController = [[MapViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 40, 320, 440)];
	//self.mapView.delegate = self;
	//self.mapView.showsUserLocation = YES;
	
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.05;
	span.longitudeDelta = 0.05;
	CLLocationCoordinate2D theLocation;
	theLocation.latitude = self.centerLocation.coordinate.latitude;
	theLocation.longitude = self.centerLocation.coordinate.longitude;
	region.center = theLocation;
	
	region.span = span;
	
	//[mapView setRegion:region animated:YES];
	//[mapView regionThatFits:region];
	
	/*
	locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 320.0, 20.0)];
	locationLabel.textAlignment = UITextAlignmentCenter;
	locationLabel.backgroundColor = [UIColor blackColor];
	locationLabel.textColor = [UIColor whiteColor];
	locationLabel.text = @"Loading restaurants near you...";
	
	[contentView addSubview:locationLabel];
	
	debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 330.0, 320.0, 30.0)];
	debugLabel.textAlignment = UITextAlignmentCenter;
	debugLabel.text = @"Waiting...";
	
	//[contentView addSubview:debugLabel];
	
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	searchBar.tintColor = [UIColor blackColor];
	searchBar.placeholder = @"Search Locations";
	searchBar.delegate = self;
	[contentView addSubview:searchBar];
	[searchBar release];
	*/
	UIImageView *tabView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 407, 320, 55)];
	[tabView setImage:[UIImage imageNamed:@"tabbar.png"]];
	[contentView addSubview:tabView];
	[tabView release];
	
	/*
	// make buttons for content stuff
	int leftDistance = 275;
	
	
	self.btnContentKml = [[UIButton alloc] initWithFrame:CGRectMake(leftDistance, 413, 40, 42)];
	[self.btnContentKml setImage:[UIImage imageNamed:@"contentmarker.png"] forState:UIControlStateNormal];
	[self.btnContentKml addTarget:self action:@selector(contentKmlClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	
	[self.contentView addSubview:self.btnContentKml];
	
	leftDistance = leftDistance - 45;
	
	
	self.btnContentWiki = [[UIButton alloc] initWithFrame:CGRectMake(leftDistance, 414, 40, 42)];
	[self.btnContentWiki setImage:[UIImage imageNamed:@"contentwiki.png"] forState:UIControlStateNormal];
	[self.btnContentWiki addTarget:self action:@selector(contentWikiClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	
	[self.contentView addSubview:self.btnContentWiki];
	
	leftDistance = leftDistance - 45;
	
	self.btnContentFlickr = [[UIButton alloc] initWithFrame:CGRectMake(leftDistance, 412, 40, 42)];
	[self.btnContentFlickr setImage:[UIImage imageNamed:@"contentflickr.png"] forState:UIControlStateNormal];
	[self.btnContentFlickr addTarget:self action:@selector(contentFlickrClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
	
	[self.contentView addSubview:self.btnContentFlickr];
	
	leftDistance = leftDistance - 45;
	
	self.btnContentTwitter = [[UIButton alloc] initWithFrame:CGRectMake(leftDistance, 413, 40, 42)];
	[self.btnContentTwitter setImage:[UIImage imageNamed:@"contenttwitter.png"] forState:UIControlStateNormal];
	[self.btnContentTwitter addTarget:self action:@selector(contentTwitterClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	
	[self.contentView addSubview:self.btnContentTwitter];
	
	leftDistance = leftDistance - 45;
	
	self.btnContentBing = [[UIButton alloc] initWithFrame:CGRectMake(leftDistance, 413, 40, 42)];
	[self.btnContentBing setImage:[UIImage imageNamed:@"contentbing_selected.png"] forState:UIControlStateNormal];
	[self.btnContentBing addTarget:self action:@selector(contentBingClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	
	[self.contentView addSubview:self.btnContentBing];
	
	
	self.btnCategoryPicker = [[UIButton alloc] initWithFrame:CGRectMake(52, 413, 40, 42)];
	[self.btnCategoryPicker setImage:[UIImage imageNamed:@"picklist.png"] forState:UIControlStateNormal];
	[self.btnCategoryPicker addTarget:self action:@selector(pickerClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 

	[self.contentView addSubview:self.btnCategoryPicker];
	
	self.btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(7, 413, 40, 42)];
	[self.btnSettings setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
	[self.btnSettings addTarget:self action:@selector(settingsClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
	
	[self.contentView addSubview:self.btnSettings];
	*/
	
	btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 420, 73, 29)];
	[btnDone setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
	[btnDone addTarget:self action:@selector(doneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	[self.contentView addSubview:btnDone];
	
	self.selectedPoint = [ARGeoCoordinate alloc];
	
	self.view = contentView;
	[contentView release];
}

- (void)doneClick:(id)sender {
	
	if ([self.delegate respondsToSelector:@selector(onARControllerClose)]) {
		[self.delegate onARControllerClose];
	}
	
	[self.camera dismissModalViewControllerAnimated:YES];
}

- (void)settingsClick:(id)sender {
	pickerType = 1;
	self.categoryView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 240)];
	self.categoryView.delegate = self;
	self.categoryView.dataSource = self;
	self.categoryView.showsSelectionIndicator = true;
	[self.contentView addSubview:self.categoryView];
	
	[UIView beginAnimations: nil context: @"some-pickerview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.categoryView.frame;
	tempFrame.origin.y = 200.0;
	self.categoryView.frame = tempFrame;
	
	[UIView commitAnimations];
	
	[self.categoryView selectRow:radiusSelectedIndex inComponent:0 animated:YES];
	
	self.bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, 320, 50)];
	self.bottomView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:self.bottomView];
	
	btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 420, 73, 29)];
	[btnDone setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
	[btnDone setImage:[UIImage imageNamed:@"btndone_selected.png"] forState:UIControlStateSelected];
	[btnDone addTarget:self action:@selector(settingsDoneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	[self.contentView addSubview:btnDone];
}

- (void)pickerClick:(id)sender {
	////NSLog(@"picker clicked!");
	pickerType = 0;
	
	if(self.categoryView != nil)
	{
		[self.categoryView removeFromSuperview];
		[self.categoryView release];
		[self.bottomView removeFromSuperview];
		[self.bottomView release];
	}
	
	self.categoryView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 240)];
	self.categoryView.delegate = self;
	self.categoryView.dataSource = self;
	self.categoryView.showsSelectionIndicator = true;
	[self.contentView addSubview:self.categoryView];
	
	[UIView beginAnimations: nil context: @"some-pickerview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.categoryView.frame;
	tempFrame.origin.y = 200.0;
	self.categoryView.frame = tempFrame;
	
	[UIView commitAnimations];
	
	self.bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, 320, 50)];
	self.bottomView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:self.bottomView];
	
	btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 420, 73, 29)];
	[btnDone setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
	[btnDone setImage:[UIImage imageNamed:@"btndone_selected.png"] forState:UIControlStateSelected];
	[btnDone addTarget:self action:@selector(catDoneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	[self.contentView addSubview:btnDone];
}

- (void)settingsDoneClick:(id)sender {
	
	if(currentSelectedRadius == @"1 mile")
	{
		radiusSelectedIndex = 0;
		currentRadius = @"1";
	}
	if(currentSelectedRadius == @"2 miles")
	{
		radiusSelectedIndex = 1;
		currentRadius = @"2";
	}
	if(currentSelectedRadius == @"3 miles")
	{
		radiusSelectedIndex = 2;
		currentRadius = @"3";
	}
	if(currentSelectedRadius == @"5 miles")
	{
		radiusSelectedIndex = 3;
		currentRadius = @"5";
	}
	if(currentSelectedRadius == @"10 miles")
	{
		radiusSelectedIndex = 4;
		currentRadius = @"10";
	}
	if(currentSelectedRadius == @"15 miles")
	{
		radiusSelectedIndex = 5;
		currentRadius = @"15";
	}
	if(currentSelectedRadius == @"25 miles")
	{
		radiusSelectedIndex = 6;
		currentRadius = @"25";
	}
	if(currentSelectedRadius == @"50 miles")
	{
		radiusSelectedIndex = 7;
		currentRadius = @"50";
	}
	
	[UIView beginAnimations: nil context: @"some-pickerview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.categoryView.frame;
	tempFrame.origin.y = 480.0;
	self.categoryView.frame = tempFrame;
	self.bottomView.alpha = 0;
	
	[UIView commitAnimations];

	[btnDone removeFromSuperview];
	[btnDone release];
	
	////NSLog(searchBar.text);
	
	if(searchBar.text != @"" && searchBar.text != nil)
		currentBingQuery = searchBar.text;
	
	if(currentBingQuery == @"" || currentBingQuery == nil)
		currentBingQuery = @"Nearby Restaurants";
	
	////NSLog(currentSelectedRadius);
	////NSLog(currentBingQuery);
	/*
	if(contentType == 0)
	{
		if(self.shuttle != nil)
		{
			[self.shuttle release];
			self.shuttle = [[YahooLocalDataShuttle alloc] init];
		}
		
		locationLabel.text = @"Loading from bing...";
		
		self.shuttle.query = currentBingQuery;
		self.shuttle.radius = currentRadius;
		self.shuttle.currentLocation = self.centerLocation;
		
		self.shuttle.currentLocation = self.centerLocation;
		[self.shuttle getData];
	}
	else if(contentType == 1)
	{
		if(self.twitterShuttle != nil)
		{
			[self.twitterShuttle release];
			self.twitterShuttle = [[TwitterLocationDataShuttle alloc] init];
		}
		
		locationLabel.text = @"Loading nearby tweets...";
		
		self.twitterShuttle.radius = currentRadius;
		self.twitterShuttle.currentLocation = self.centerLocation;
		[self.twitterShuttle getData];
	}
	else if(contentType == 2)
	{
		if(self.flickrShuttle != nil)
		{
			[self.flickrShuttle release];
			self.flickrShuttle = [[FlickrLocationDataShuttle alloc] init];
		}
		
		locationLabel.text = @"Loading nearby flickr images...";
		
		self.flickrShuttle.radius = currentRadius;
		self.flickrShuttle.currentLocation = self.centerLocation;
		[self.flickrShuttle getData];
	}
	else if(contentType == 4)
	{
		if(self.wikiShuttle != nil)
		{
			[self.wikiShuttle release];
			self.wikiShuttle = [[WikipediaLocationDataShuttle alloc] init];
		}
		
		locationLabel.text = @"Loading nearby flickr images...";
		
		self.wikiShuttle.radius = currentRadius;
		self.wikiShuttle.currentLocation = self.centerLocation;
		[self.wikiShuttle getData];
	}
	*/
	////NSLog([NSString stringWithFormat:@"loading new data with radius: %@", currentRadius]);
}

- (void)catKmlDoneClick:(id)sender {
	[UIView beginAnimations: nil context: @"some-tableview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.myMapsTable.frame;
	tempFrame.origin.y = -480;
	self.myMapsTable.frame = tempFrame;
	
	[UIView commitAnimations];
	
	[btnDone removeFromSuperview];
	[self.bottomView removeFromSuperview];
	
	[btnDone release];
	[self.bottomView release];
}

- (void)catDoneClick:(id)sender {
	
	pickerType = 1;
	
	currentBingQuery = currentSelectedCategory;
	
	////NSLog(@"cat done clicked.");
	lastRowCount = 0;
	/*
	if(self.shuttle != nil)
	{
		[self.shuttle release];
		self.shuttle = [[YahooLocalDataShuttle alloc] init];
	}
	 */
	[self resetContentButtons];
	contentType = 0;
	[self.btnContentBing setImage:[UIImage imageNamed:@"contentbing_selected.png"] forState:UIControlStateNormal];
	locationLabel.text = @"Loading from bing...";
	 
	CGRect tempFrame = searchBar.frame;
	tempFrame.origin.y = 0.0f;
	searchBar.frame = tempFrame;
	
	if(currentBingQuery == @"" || currentBingQuery == nil)
		currentBingQuery = @"Nearby Restaurants";
	
	[UIView beginAnimations: nil context: @"some-pickerview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame2 = self.categoryView.frame;
	tempFrame2.origin.y = 480.0;
	self.categoryView.frame = tempFrame2;
	self.bottomView.alpha = 0;
	
	[UIView commitAnimations];
	
	[btnDone removeFromSuperview];
	[btnDone release];
	
	//self.shuttle.query = currentBingQuery;
	//self.shuttle.radius = currentRadius;
	
	//self.shuttle.currentLocation = self.centerLocation;
	//[self.shuttle getData];
}

- (void)didGrabImage:(UIImage *)image {
	self.popupView.image = image;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if(pickerType == 0)
		return theCategories.count;
	else if(pickerType == 1)
		return theRadius.count;
	
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if(pickerType == 0)
		return [theCategories objectAtIndex:row];
	else if(pickerType == 1)
		return [theRadius objectAtIndex:row];
	
	return @"";
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	if(pickerType == 0)
	{
		currentSelectedCategory = [theCategories objectAtIndex:row];
	}
	else if(pickerType == 1)
	{
		currentSelectedRadius = [theRadius objectAtIndex:row];
	}
}

- (void)resetContentButtons {
	[self.btnContentBing setImage:[UIImage imageNamed:@"contentbing.png"] forState:UIControlStateNormal];
	[self.btnContentTwitter setImage:[UIImage imageNamed:@"contenttwitter.png"] forState:UIControlStateNormal];
	[self.btnContentFlickr setImage:[UIImage imageNamed:@"contentflickr.png"] forState:UIControlStateNormal];
	[self.btnContentKml setImage:[UIImage imageNamed:@"contentmarker.png"] forState:UIControlStateNormal];
	[self.btnContentWiki setImage:[UIImage imageNamed:@"contentwiki.png"] forState:UIControlStateNormal];
	
	// hide all existing coordinates in the view
	int index = 0;
	for (ARCoordinate *item in self.locationItems) {
		
		UIView *viewToDraw = [self.locationViews objectAtIndex:index];
		[viewToDraw removeFromSuperview];
		
		index++;
	}
	
	shouldResetMapView = true;
}

- (void)contentBingClick:(id)sender {
	/*
	if(contentType != 0)
	{
		lastRowCount = 0;
		if(self.shuttle != nil)
		{
			[self.shuttle release];
			self.shuttle = [[YahooLocalDataShuttle alloc] init];
		}
		//NSLog(@"bing clicked!");
		////NSLog([NSString stringWithFormat:@"current bing query: %@", currentBingQuery]);
		[self resetContentButtons];
		contentType = 0;
		[self.btnContentBing setImage:[UIImage imageNamed:@"contentbing_selected.png"] forState:UIControlStateNormal];
		locationLabel.text = @"Loading from bing...";
		
		CGRect tempFrame = searchBar.frame;
		tempFrame.origin.y = 0.0f;
		searchBar.frame = tempFrame;
		
		if(searchBar.text != @"" && searchBar.text != nil)
			currentBingQuery = searchBar.text;
		else
			currentBingQuery = @"nearby restaurants";
		
		self.shuttle.query = currentBingQuery;
		self.shuttle.radius = currentRadius;
		
		self.shuttle.currentLocation = self.centerLocation;
		[self.shuttle getData];
	}
	 */
}

- (void)contentTwitterClick:(id)sender {
	/*
	if(contentType != 1)
	{
		CGRect tempFrame = searchBar.frame;
		tempFrame.origin.y = 480.0f;
		searchBar.frame = tempFrame;
		
		lastRowCount = 0;
		[self.twitterShuttle release];
		self.twitterShuttle = [[TwitterLocationDataShuttle alloc] init];
		[self resetContentButtons];
		contentType = 1;
		[self.btnContentTwitter setImage:[UIImage imageNamed:@"contenttwitter_selected.png"] forState:UIControlStateNormal];
		locationLabel.text = @"Loading nearby tweets...";
		self.twitterShuttle.radius = currentRadius;
		self.twitterShuttle.currentLocation = self.centerLocation;
		[self.twitterShuttle getData];
	}
	 */
}

- (void)contentFlickrClick:(id)sender {
	/*
	if(contentType != 2)
	{
		CGRect tempFrame = searchBar.frame;
		tempFrame.origin.y = 480.0f;
		searchBar.frame = tempFrame;
		
		lastRowCount = 0;
		[self.flickrShuttle release];
		self.flickrShuttle = [[FlickrLocationDataShuttle alloc] init];
		[self resetContentButtons];
		contentType = 2;
		[self.btnContentFlickr setImage:[UIImage imageNamed:@"contentflickr_selected.png"] forState:UIControlStateNormal];
		locationLabel.text = @"Loading nearby flickr images...";
		self.flickrShuttle.radius = currentRadius;
		self.flickrShuttle.currentLocation = self.centerLocation;
		[self.flickrShuttle getData];
	}	
	 */
}

- (void)contentWikiClick:(id)sender {
	/*
	if(contentType != 4)
	{
		CGRect tempFrame = searchBar.frame;
		tempFrame.origin.y = 480.0f;
		searchBar.frame = tempFrame;
		
		lastRowCount = 0;
		[self.wikiShuttle release];
		self.wikiShuttle = [[WikipediaLocationDataShuttle alloc] init];
		[self resetContentButtons];
		contentType = 4;
		[self.btnContentWiki setImage:[UIImage imageNamed:@"contentwiki_selected.png"] forState:UIControlStateNormal];
		locationLabel.text = @"Loading nearby Wikipedia entries...";
		self.wikiShuttle.radius = currentRadius;
		self.wikiShuttle.currentLocation = self.centerLocation;
		NSLog(@"calling wiki..");
		[self.wikiShuttle getData];
	}	
	 */
}

- (void)contentKmlClick:(id)sender {
	/*
	//if(contentType != 3)
//	{
		CGRect tempFrame2 = searchBar.frame;
		tempFrame2.origin.y = 480.0f;
		searchBar.frame = tempFrame2;
		
		
		lastRowCount = 0;
		[self.kmlShuttle release];
		self.kmlShuttle = [[KmlLocationDataShuttle alloc] init];
		[self resetContentButtons];
		contentType = 3;
		[self.btnContentKml setImage:[UIImage imageNamed:@"contentmarker_selected.png"] forState:UIControlStateNormal];
		locationLabel.text = @"Loading custom map...";
		//self.kmlShuttle.query = @"111134431028788831178.000472eec4bafd4167bd4";
		self.kmlShuttle.query = [[NSUserDefaults standardUserDefaults] stringForKey:@"name_preference"];
		self.kmlShuttle.radius = currentRadius;
		self.kmlShuttle.currentLocation = self.centerLocation;
		[self.kmlShuttle getData];
		 
		
	/*
		[UIView beginAnimations: nil context: @"some-tableview-identifier"];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration: 0.4f];
		
		CGRect tempFrame = self.myMapsTable.frame;
		tempFrame.origin.y = 0;
		self.myMapsTable.frame = tempFrame;
		
		[UIView commitAnimations];
		
		self.bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, 320, 40)];
		self.bottomView.backgroundColor = [UIColor blackColor];
		[self.contentView addSubview:self.bottomView];
		
		btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 420, 73, 29)];
		[btnDone setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
		[btnDone setImage:[UIImage imageNamed:@"btndone_selected.png"] forState:UIControlStateSelected];
		[btnDone addTarget:self action:@selector(catKmlDoneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
		[self.contentView addSubview:btnDone];
	
		btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(260, 420, 73, 29)];
		[btnAdd setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
		[btnAdd addTarget:self action:@selector(addMapFormClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
		[self.contentView addSubview:btnAdd];
	 */
	
//	}
}
	
- (void)addMapFormClick:(id)sender {
	/*
	if(mapController == nil)
		mapController = [[AddMyMap alloc] initWithNibName:@"AddMyMap" bundle:nil];
	
	CGRect tempFrame = mapController.view.frame;
	tempFrame.origin.x = 320.0f;
	mapController.view.frame = tempFrame;
	
	[self.contentView addSubview:mapController.view];
	
	[UIView beginAnimations: nil context: @"some-mapformadd-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame2 = mapController.view.frame;
	tempFrame2.origin.x = 0;
	mapController.view.frame = tempFrame2;
	
	[UIView commitAnimations];
	*/
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theBar
{
	/*
	//NSLog(@"search clicked");
	if(self.categoryView.frame.origin.y != 480.0)
	{
		//NSLog(@"category view on");
		[UIView beginAnimations: nil context: @"some-pickerview-identifier"];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration: 0.4f];
		
		CGRect tempFrame2 = self.categoryView.frame;
		tempFrame2.origin.y = 480.0;
		self.categoryView.frame = tempFrame2;
		self.bottomView.alpha = 0;
		
		[UIView commitAnimations];
		
		[btnDone removeFromSuperview];
		[btnDone release];	
	}
	
	locationLabel.text = @"Loading from bing...";
	lastRowCount = 0;
	[self.shuttle release];
	self.shuttle = [[YahooLocalDataShuttle alloc]init]; 
	self.shuttle.query = searchBar.text;
	self.shuttle.radius = currentRadius;
	currentBingQuery = searchBar.text;
	self.shuttle.currentLocation = self.centerLocation;
	[self.shuttle getData];
	[theBar resignFirstResponder];
	 */
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theBar
{
	theBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theBar
{
	theBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theBar
{
	theBar.text = @"";
	[theBar resignFirstResponder];
}


-  (void)searchClick:(id)sender {  
	/*
	//debugLabel.text = [NSString stringWithFormat:@"clicked btn, search text: %@", searchField.text];
	[self.shuttle release];
	self.shuttle = [[YahooLocalDataShuttle alloc]init]; 
	self.shuttle.query = searchField.text;
	self.shuttle.radius = currentRadius;
	self.shuttle.currentLocation = self.centerLocation;
	[self.shuttle getData];
	 */
 } 

- (void)searchFieldFinishedEditing:(UITextField *)theTextField {
	//self.shuttle.query = searchField.text;
	//[self.shuttle getData];
	//self.shuttle.didSetLocations = false;
	//debugLabel.text = @"finished editing";
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed
	[searchField resignFirstResponder];
	return YES;
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
	
	/*
	double rotationWindow = .1845;
	// check for rotation 
	if(result)
	{
		if(coordinate.azimuth > leftAzimuth && coordinate.azimuth < (leftAzimuth + rotationWindow))
			coordinate.rotateLeft = true;
		if(coordinate.azimuth < rightAzimuth && coordinate.azimuth > (rightAzimuth - rotationWindow))
			coordinate.rotateRight = true;
	}
	 */
	
	//locationLabel.text = [NSString stringWithFormat:@"left: %.3f center: %.3f right: %.3f", leftAzimuth, centerAzimuth, rightAzimuth];
	
	double centerInclination = self.centerCoordinate.inclination;
	//locationLabel.text = [NSString stringWithFormat:@"inclination: %.4f", self.centerCoordinate.inclination];
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
    // Disable future updates to save power.
    //[manager stopUpdatingLocation];
	
	self.centerLocation = newLocation;
	
	//locationLabel.text = [newLocation description];
	
	//self.shuttle.query = @"Nearby Restaurants";
	//self.shuttle.currentLocation = newLocation;
	//self.twitterShuttle.currentLocation = newLocation;
	//self.flickrShuttle.currentLocation = newLocation;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.01;
	span.longitudeDelta = 0.01;
	CLLocationCoordinate2D theLocation;
	theLocation.latitude = self.centerLocation.coordinate.latitude;
	theLocation.longitude = self.centerLocation.coordinate.longitude;
	region.center = theLocation;
	
	region.span = span;
	
	if(recalibrateProximity)
	{
		recalibrateProximity = false;
		[self updateProximityLocations];
	}
	
	/*
	[mapView setRegion:region animated:YES];
	[mapView regionThatFits:region];
	
	if(isInitialQuery == true)
	{
		self.shuttle.query = currentBingQuery;
		self.shuttle.radius = currentRadius;
		[self.shuttle getData];
	}
	else
	{
		debugLabel.text = [newLocation description];
	}
	 */
	
	//NSString *msg = [NSString stringWithFormat:@"Finished Parsing. %i items loaded.", self.shuttle.coordinateList.count];
	//locationLabel.text = msg;
	
	//NSLog(@"Location Updated...");
	
	locationLabel.text = @"location updated...";
	
	/*
	switch(contentType)
	{
		case 2:
			self.flickrShuttle.didSetLocations = false;
			break;
		case 1:
			self.twitterShuttle.didSetLocations = false;
			break;
		case 0:
			self.shuttle.didSetLocations = false;
			break;
	}*/
	
	for (ARGeoCoordinate *geoLocation in self.locationItems) {
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
		}
	}
	
	[self updateLocations];
}

- (void) updateProximityLocations
{
	NSLog(@"update proximity locations..");
	[locationItems release];
	locationItems = [[NSMutableArray alloc] init];
	
	for(ARGeoCoordinate *geoCoordinate in baseItems)
	{
		[geoCoordinate.subLocations release];
		geoCoordinate.isMultiple = false;
		[geoCoordinate calibrateUsingOrigin:centerLocation];
		
		if(geoCoordinate.radialDistance < self.minDistance)
		{
			self.minDistance = geoCoordinate.radialDistance;
			NSLog(@"distance: %.8f", geoCoordinate.radialDistance);
		}
		
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
	}
}

- (bool)isNearCoordinate:(ARGeoCoordinate *)coord newCoordinate:(ARGeoCoordinate *)newCoord
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
bool mapViewOn = false;

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
	
	/*
	if(rollingZ <= -.98 && mapViewOn == false)
	{
		//mapViewOn = true;
		//[self resetMapView];
//		[self.contentView addSubview:self.mapView];
	}
	else if(rollingZ >= -.78 && mapViewOn == true)
	{
		[self removeMapView];
		mapViewOn = false;
	}
	 */
	
	//debugLabel.text = [NSString stringWithFormat:@"z: %.8f", rollingZ];
	
	[self updateLocations];
}

- (void) createMapView
{
	if (!self.locationViews || !self.locationItems) {
		return;
	}
	
	AddressAnnotation *ann;
	int i = 0;
	for(ARGeoCoordinate *coord in self.locationItems)
	{
		CLLocationCoordinate2D theLocation;
		theLocation.latitude = coord.geoLocation.coordinate.latitude;
		theLocation.longitude = coord.geoLocation.coordinate.longitude;
		
		ann = [[AddressAnnotation alloc] initWithCoordinate:theLocation];
		ann.mTitle = coord.title;
		ann.mSubTitle = [NSString stringWithFormat:@"%.1f miles", coord.radialDistance];
		
		//[mapView addAnnotation:ann];
		[ann release];
			
		i++;
	}
	
	//region.center = theLocation;
	
	// rotation fun.
	//CABasicAnimation *rotationAnimation;
	//rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	//rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
	//rotationAnimation.toValue = [NSNumber numberWithFloat:radians(40)];
	//rotationAnimation.duration = 0.5;
	//[self.mapView addAnimation:rotationAnimation forKey:@"40"];
}

- (void) resetMapView
{
	/*
	if(self.mapView != nil)
	{
		[self.mapView removeFromSuperview];
		[self.mapView release];
	}
	
	if (!self.locationViews || !self.locationItems) {
		return;
	}
	
	int topPoint = 40;
	int height = 440;
	
	if(contentType > 0)
	{
		topPoint = 0;
		height = 480;
	}
	
	//self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, topPoint, 320, height)];
	//self.mapView.delegate = self;
	//self.mapView.showsUserLocation = YES;
	
	double mapZoom = 0.01;
	
	switch(radiusSelectedIndex)
	{
		case 0:
			mapZoom = 0.009;
			break;
		case 1:
			mapZoom = .018;
			break;
		case 2:
		default:
			mapZoom = 0.03;
			break;
		case 3:
			mapZoom = .06;
			break;
		case 4:
			mapZoom = .2;
			break;
		case 5:
			mapZoom = .25;
			break;
		case 6:
			mapZoom = .5;
			break;
		case 7:
			mapZoom = 1;
			break;
	}
	
	MKCoordinateSpan span;
	span.latitudeDelta = mapZoom;
	span.longitudeDelta = mapZoom;
	CLLocationCoordinate2D theLocation;
	theLocation.latitude = self.centerLocation.coordinate.latitude;
	theLocation.longitude = self.centerLocation.coordinate.longitude;
	region.center = theLocation;
	
	region.span = span;
	
	[mapView setRegion:region animated:YES];
	[mapView regionThatFits:region];
	[self createMapView];

	if(mapViewOn == true)
	{
		
		self.mapView.alpha = 0;
		[self.contentView addSubview:self.mapView];
		
		[UIView beginAnimations: nil context: @"some-map-alpha-identifier"];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration: 0.6f];
		
		self.mapView.alpha = 1;
		
		[UIView commitAnimations];
	}
	 */
}

- (void) removeMapView
{	
	
	[UIView beginAnimations: nil context: @"some-map-alpha-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.6f];
	
	//self.mapView.alpha = 0;
	
	[UIView commitAnimations];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
	
	//if(annotation == self.mapView.userLocation)
	//	return nil;
	
	MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myLocal"];
	//annView.pinColor = MKPinAnnotationColorGreen;
	annView.animatesDrop = TRUE;
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5,-5);
	return annView;
}

NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedDescending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
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

NSComparisonResult LeftSortFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
	if (s1.leftX > s2.leftX) {
		return NSOrderedDescending;
	} else if (s1.leftX < s2.leftX) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

/*
- (void)setLocationItems:(NSMutableArray *)newItems {
	
	NSLog(@"set locations try..");
	if([newItems count] > [locationItems count])
	{
		NSLog(@"set locations..");
		[locationItems release];
		locationItems = [newItems retain];
		
		NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:newItems];
		[sortedArray sortUsingFunction:LocationSortClosestFirst context:NULL];
		
		locationItems = [sortedArray copy];
		
		NSMutableArray *tempArray = [NSMutableArray array];
		
		for (ARGeoCoordinate *coordinate in locationItems) {
			//create the views here.
			
			//NSLog(@"creating view..");
			//call out for the delegate's view.
			if ([self.delegate respondsToSelector:@selector(viewForCoordinate:)]) {
				[tempArray addObject:[self.delegate viewForCoordinate:coordinate]];
			}
		}
		
		self.locationViews = tempArray;
	
	}
}
 */

- (void)updateLocations {
	//update locations!
	
	//[self setLocationItems:self.locationItems];
	
	//NSLog(@"update locations...");
	/*
	int index = 0;
	for (ARCoordinate *item in self.locationViews) {
		
		UIView *viewToDraw = [self.locationViews objectAtIndex:index];
		[viewToDraw removeFromSuperview];
		
		index++;
	}
	 */
	
	
	/*
	// recalibrate the locations.
	for (ARGeoCoordinate *geoLocation in self.locationItems) {
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
		}
	}
	
	NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:self.locationItems];
	
	self.locationItems = [sortedArray copy];
	*/
	
	/*
	if(self.updatedLocations == true)
	{
		NSLog(@"remaking views..");
		self.updatedLocations = false;
		
		for (UIView *view in self.locationLayerView.subviews) {
			[view removeFromSuperview];
		}
		
		NSMutableArray *tempArray = [NSMutableArray array];
		
		for (ARGeoCoordinate *coordinate in locationItems) {
			//call out for the delegate's view.
			if ([self.delegate respondsToSelector:@selector(viewForCoordinate:)]) {
				[tempArray addObject:[self.delegate viewForCoordinate:coordinate]];
			}
		}
		
		self.locationViews = tempArray;
	}
	 */
	
	if(self.baseItems.count < 25 && progressView == nil)
	{
		progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, -10, 320, 480)];
		[progressView startAnimating];
		progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		[progressView sizeToFit];
		
		[self.view addSubview:progressView];
		
	}
	else if(self.baseItems.count >= 25)
	{
		[progressView removeFromSuperview];
		//[progressView release];
	}
	
		
	unsigned int index = 0;
	
	for (ARGeoCoordinate *item in self.locationItems) {
		
		//if(index < self.locationViews.count)
		//{
			UIImageView *viewToDraw = [self.locationViews objectAtIndex:index];
			
			NSString *theImage = @"apt.png";
			if(item.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
			   item.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude)
			{
				theImage = @"apt_selected.png";
				
				if(item.isMultiple)
					theImage = @"apts_selected.png";
			}
			else 
			{
				if(item.isMultiple)
				{
					theImage = @"apts.png";
					
					for(ARGeoCoordinate *coord in item.subLocations)
					{
						if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
						   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude)
						{
							theImage = @"apts_selected.png";
						}
					}
				}
			}
		
			UIImage *img = [UIImage imageNamed:theImage];
			[viewToDraw setImage:img];
			
		
			item.leftX = -1;
			
			if ([self viewportContainsCoordinate:item]) {
				//NSLog(@"lat: %.8f long: %.8f", item.geoLocation.coordinate.latitude, item.geoLocation.coordinate.longitude);
				CGPoint loc = [self pointInView:self.view forCoordinate:item];
				
				float width = viewToDraw.frame.size.width;
				float height = viewToDraw.frame.size.height;
				
				viewToDraw.frame = CGRectMake(loc.x - width / 2.0, loc.y - width / 2.0, width, height);
				
				[self.locationLayerView addSubview:viewToDraw];
				
				
			} else {
				
				[viewToDraw removeFromSuperview];
			}
		//}
		
		index++;
	}
	
	[self.locationItemsInView release];
	self.locationItemsInView = [[NSMutableArray alloc] init];
	if(self.locationItemsInView != nil)
	{
		NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:locationItems];
		[sortedArray sortUsingFunction:LeftSortFirst context:NULL];
		self.locationItemsInView = [sortedArray copy];	
	}

}

#define BOX_WIDTH 200
#define BOX_HEIGHT 68

- (UIView *)viewForCoordinate:(ARGeoCoordinate *)coordinate {
	
	[coordinate calibrateUsingOrigin: self.centerLocation];
	
	double inclinationFactor = 33 * coordinate.radialDistance;
	
	if(coordinate.radialDistance < .5)
	{
		inclinationFactor = 27;
	}
	
	coordinate.inclination = -M_PI/inclinationFactor + .05;
	
	// bing

		CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
		NSString *theImage = @"finalpoint.png";
		
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
		
	//return nil;
}

- (bool)tableContainsItem:(ARCoordinate *)coordinate {
	bool foundCoordinate = false;
	
	for(ARCoordinate *item in self.locationItemsInView)
	{
		if(coordinate.title == item.title && coordinate.radialDistance == item.radialDistance)
			foundCoordinate = true;
	}
	
	return foundCoordinate;
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
			self.selectedPoint = [ARGeoCoordinate alloc];
			self.selectedPoint = (ARGeoCoordinate *)[self.locationItems objectAtIndex:index];
			
			[self makePanel];
			
			[UIView beginAnimations: nil context: @"some-identifier-used-by-a-delegate-if-set"];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration: 0.4f];
			
			double topPoint = 190.0f;
			
			if(contentType == 2)
				topPoint = 110.0f;
			else if(contentType == 1)
				topPoint = 151.0f;
			
			CGRect tempFrame = popupView.frame;
			tempFrame.origin.y = topPoint;
			self.popupView.frame = tempFrame;
			
			popupIsAdded = true;
			//NSLog([NSString stringWithFormat:@"popup animate to top: %.1f", topPoint]);
			[UIView commitAnimations];
			
			/*
			if(contentType == 2 && self.selectedPoint.bigImgIsSet == false)
			{
				//NSLog([NSString stringWithFormat:@"big img: %@", self.selectedPoint.bigimg]);
				NSString *urlString = self.selectedPoint.bigimg;
				NSURL *url = [NSURL URLWithString:urlString];
				UIImage *image = [[UIImage imageWithData: [NSData dataWithContentsOfURL: url]] retain];
			
				UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 45, image.size.width, image.size.height)];
				theView.image = image;
				self.selectedPoint.largeImg = image;
				
				self.selectedPoint.bigImgIsSet = true;
				
				[self.popupView addSubview:theView];
			}
			
			if(contentType == 2)
			{
				int leftPoint = 26;
				int width = 240;
				int height = 180;
				
				if(self.selectedPoint.bigImgView == nil)
				{
					self.selectedPoint.bigImgView = [[[AsyncImageView alloc] init] autorelease];
					self.selectedPoint.bigImgView.tag = 999;
					NSURL *url = [NSURL URLWithString:self.selectedPoint.bigimg];
					[self.selectedPoint.bigImgView loadImageFromURL:url];
					
					CGRect frame = CGRectMake(leftPoint, 55, width, height);
					self.selectedPoint.bigImgView.frame = frame;
				}
				else
				{
					if(self.selectedPoint.largeImg.size.height > self.selectedPoint.largeImg.size.width)
						leftPoint = 56;
					
					CGRect frame = CGRectMake(leftPoint, 55, self.selectedPoint.largeImg.size.width, self.selectedPoint.largeImg.size.height);
					self.selectedPoint.bigImgView.frame = frame;
					
					//NSLog(@"initial load, found from cache!");
				}
				
				[self.popupView addSubview:self.selectedPoint.bigImgView];
			}
			*/ 
		}
		
		index++;
	}
	}
	
}

- (void)getNextPanel {
	/*
	// move current panel out left
	[UIView beginAnimations: nil context: @"outleftanimation"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = popupView.frame;
	tempFrame.origin.x = -320.0f;
	self.popupView.frame = tempFrame;
	
	[UIView commitAnimations];
	
	[self makePanel];
	self.popupView.frame = CGRectMake(320, 480, 320, 200);
	
	[UIView beginAnimations: nil context: @"inleftanimation"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	tempFrame = popupView.frame;
	tempFrame.origin.x = 0.0f;
	self.popupView.frame = tempFrame;
	
	[UIView commitAnimations];
	 */
	
	int index = 0;
	int currentIndex = 0;
	
	/*
	for(ARGeoCoordinate *coord in self.locationItemsInView)
	{
		if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
		   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude
			&& coord.title == self.selectedPoint.title)
		{
			currentIndex = index + 1;
		}
		
		index++;
	}
	 */
	
	for(ARGeoCoordinate *coord in self.selectedPoint.subLocations)
	{
		if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
		   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude
		   && coord.title == self.selectedPoint.title)
		{
			currentIndex = index + 1;
		}
		
		index++;
	}
	
	if(currentIndex > index - 1)
		currentIndex = 0;
	
	NSMutableArray *subLocations = [[NSMutableArray	alloc] init];
	subLocations = self.selectedPoint.subLocations;
		
	
	self.selectedPoint = [ARGeoCoordinate alloc];
	self.selectedPoint = (ARGeoCoordinate *)[subLocations objectAtIndex:currentIndex];
	self.selectedPoint.subLocations = subLocations;
	[self.selectedPoint calibrateUsingOrigin: self.centerLocation];
	
	shouldChangeHighlight = false;
	
	[self makePanel];
	
	/*
	if(contentType == 2 && self.selectedPoint.bigImgIsSet == false)
	{
		//NSLog([NSString stringWithFormat:@"big img: %@", self.selectedPoint.bigimg]);
		NSString *urlString = self.selectedPoint.bigimg;
		NSURL *url = [NSURL URLWithString:urlString];
		UIImage *image = [[UIImage imageWithData: [NSData dataWithContentsOfURL: url]] retain];
		
		UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 45, image.size.width, image.size.height)];
		theView.image = image;
		self.selectedPoint.largeImg = image;
		
		self.selectedPoint.bigImgIsSet = true;
		
		[self.popupView addSubview:theView];
	}
	 
	
	if(contentType == 2)
	{
		int leftPoint = 26;
		if(self.selectedPoint.bigImgView.image.size.height > self.selectedPoint.bigImgView.image.size.width)
			leftPoint = 56;
		
		if(self.selectedPoint.bigImgView == nil)
		{
			self.selectedPoint.bigImgView = [[[AsyncImageView alloc] init] autorelease];
			self.selectedPoint.bigImgView.tag = 999;
			NSURL *url = [NSURL URLWithString:self.selectedPoint.bigimg];
			[self.selectedPoint.bigImgView loadImageFromURL:url];
		}
		
		CGRect frame = CGRectMake(leftPoint, 55, self.selectedPoint.bigImgView.image.size.width, self.selectedPoint.bigImgView.image.size.height);
		self.selectedPoint.bigImgView.frame = frame;
		
		[self.popupView addSubview:self.selectedPoint.bigImgView];
	}
	 */
}
	
- (void)getPrevPanel {
	int index = 0;
	int currentIndex = 0;
	
	for(ARGeoCoordinate *coord in self.selectedPoint.subLocations)
	{
		if(coord.geoLocation.coordinate.latitude == self.selectedPoint.geoLocation.coordinate.latitude && 
		   coord.geoLocation.coordinate.longitude == self.selectedPoint.geoLocation.coordinate.longitude
			&& coord.title == self.selectedPoint.title)
		{
			currentIndex = index - 1;
		}
		
		index++;
	}
	
	if(currentIndex < 0)
		currentIndex = index - 1;
	
	NSMutableArray *subLocations = [[NSMutableArray	alloc] init];
	subLocations = self.selectedPoint.subLocations;
	
	
	self.selectedPoint = [ARGeoCoordinate alloc];
	self.selectedPoint = (ARGeoCoordinate *)[subLocations objectAtIndex:currentIndex];
	self.selectedPoint.subLocations = subLocations;
	[self.selectedPoint calibrateUsingOrigin: self.centerLocation];
	
	shouldChangeHighlight = false;
	
	[self makePanel];
	
	/*
	if(contentType == 2 && self.selectedPoint.bigImgIsSet == false)
	{
		//NSLog([NSString stringWithFormat:@"big img: %@", self.selectedPoint.bigimg]);
		NSString *urlString = self.selectedPoint.bigimg;
		NSURL *url = [NSURL URLWithString:urlString];
		UIImage *image = [[UIImage imageWithData: [NSData dataWithContentsOfURL: url]] retain];
		
		UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 45, image.size.width, image.size.height)];
		theView.image = image;
		self.selectedPoint.largeImg = image;
		
		self.selectedPoint.bigImgIsSet = true;
		
		[self.popupView addSubview:theView];
	}
	else if(contentType == 2)
	{
		int leftPoint = 26;
		if(self.selectedPoint.bigImgView.image.size.height > self.selectedPoint.bigImgView.image.size.width)
			leftPoint = 56;
		
		//UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPoint, 55, self.selectedPoint.largeImg.size.width, self.selectedPoint.largeImg.size.height)];
		//theView.image = self.selectedPoint.largeImg;
		
		if(self.selectedPoint.bigImgView == nil)
		{
			self.selectedPoint.bigImgView = [[[AsyncImageView alloc] init] autorelease];
			self.selectedPoint.bigImgView.tag = 999;
			NSURL *url = [NSURL URLWithString:self.selectedPoint.bigimg];
			[self.selectedPoint.bigImgView loadImageFromURL:url];
		}
		
		CGRect frame = CGRectMake(leftPoint, 55, self.selectedPoint.bigImgView.image.size.width, self.selectedPoint.bigImgView.image.size.height);
		self.selectedPoint.bigImgView.frame = frame;
		
		[self.popupView addSubview:self.selectedPoint.bigImgView];
	}
	 */
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

	// no zipcode! aargh.
	if(self.selectedPoint.zipcode == nil)
	{
		self.selectedPoint.zipcode = [NSString alloc];
		self.selectedPoint.zipcode = @"";
	}
	
	int topPoint = 480;
	
	if(popupIsAdded)
		topPoint = 190;
	
	self.popupView = [[UIView alloc] initWithFrame:CGRectMake(14, topPoint, 292, 215)];
	
	//self.popupView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"content5.png"]];
	//self.popupView.backgroundColor = [UIColor blackColor];
	//self.popupView.alpha = .9;
	
	[self.view addSubview:self.popupView];
	popupIsAdded = true;
	
	int buttonStart = 19;
	
	UIImageView *theImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 292, 215)];
	[theImgView setImage:[UIImage imageNamed:@"bg_content_bing.png"]];
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
	[btnClose setImage:[UIImage imageNamed:@"closeicon.png"] forState:UIControlStateNormal];
	[btnClose addTarget:self action:@selector(panelCloseClick:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
	
	[self.popupView addSubview:btnClose];
	[btnClose release];

	// to pop the details view.
	
	UIButton *detailsButton = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] initWithFrame:CGRectMake(250, 10, 30, 28)];
	
	// figure out the tag for the details button
	int theTag = 0;
	int x = 0;
	for(ARGeoCoordinate *baseCoord in self.baseItems)
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
		[btnNextArrow setImage:[UIImage imageNamed:@"rightarrow.png"] forState:UIControlStateNormal];
		[btnNextArrow addTarget:self action:@selector(nextClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	
		[self.popupView addSubview:btnNextArrow];
		[btnNextArrow release];
	
		UIButton *btnPrevArrow = [[UIButton alloc] initWithFrame:CGRectMake(-8, 143, 50, 62)];
		[btnPrevArrow setImage:[UIImage imageNamed:@"leftarrow.png"] forState:UIControlStateNormal];
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
	tempFrame.origin.y = 480.0f;
	self.popupView.frame = tempFrame;
	
	[UIView commitAnimations];
	
	popupIsAdded = false;
}

- (void)tweetTitleClick:(id)sender {
	
	/*
	alertType = 3;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This will open this person's profile in Safari. Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [alertView release];
	 */
	
	[self loadWebView:[NSString stringWithFormat:@"http://www.twitter.com/%@", self.selectedPoint.author]];
}

- (void)flickrTitleClick:(id)sender {
	
	/*
	alertType = 4;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This will load this image in Safari. Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [alertView release];
	 */
	
	locationLabel.text = self.selectedPoint.author;
	[self loadWebView:[NSString stringWithFormat:@"http://m.flickr.com/photos/%@/", self.selectedPoint.theId]];
}

- (void)nextClick:(id)sender {
	[self getNextPanel];
}

- (void)prevClick:(id)sender {
	[self getPrevPanel];
}

-  (void)callClick:(id)sender {  
	
	alertType = 0;
	//UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to call %@ ?", self.selectedPoint.phone] message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    //[alertView show];
    //[alertView release];
	
} 

-  (void)mapsClick:(id)sender {  
	
    alertType = 1;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This will launch driving directions in Maps. Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [alertView release];
}

-  (void)bingClick:(id)sender {  
	
	/*
	alertType = 2;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This will open info and reviews in Safari from Bing. Are you sure?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [alertView release];
	 */
	
	//NSLog([NSString stringWithFormat:@"url: %@", self.selectedPoint.url]);
	[self loadWebView:self.selectedPoint.url];
	
}

- (void)loadWebView:(NSString *)url {
	
	if(self.webView != nil)
	{
		[self.webView removeFromSuperview];
		[self.webView release];
	}
	
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -480, 320, 410)];
	
	NSURL *theUrl = [NSURL URLWithString:url];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theUrl];
	
	[self.webView loadRequest:theRequest];
	self.webView.scalesPageToFit = true;
	
	[self.contentView addSubview:self.webView];
	
	self.bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, 320, 50)];
	self.bottomView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:self.bottomView];
	
	btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 420, 73, 29)];
	[btnDone setImage:[UIImage imageNamed:@"btndone.png"] forState:UIControlStateNormal];
	[btnDone setImage:[UIImage imageNamed:@"btndone_selected.png"] forState:UIControlStateSelected];
	[btnDone addTarget:self action:@selector(webviewDoneClick:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside]; 
	[self.contentView addSubview:btnDone];
	
	
	[UIView beginAnimations: nil context: @"some-webview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.webView.frame;
	tempFrame.origin.y = 0.0f;
	self.webView.frame = tempFrame;
	
	[UIView commitAnimations];
}

- (void)webviewDoneClick:(id)sender {
	
	[self.bottomView removeFromSuperview];
	[self.bottomView release];
	[btnDone removeFromSuperview];
	[btnDone release];
	
	[UIView beginAnimations: nil context: @"some-webview-identifier"];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.4f];
	
	CGRect tempFrame = self.webView.frame;
	tempFrame.origin.y = -480.0f;
	self.webView.frame = tempFrame;
	
	[UIView commitAnimations];
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//UITouch *touch = [touches anyObject];
	//CGPoint currentPosition = [touch locationInView:self.view];
	//CGFloat deltaX = fabsf(gestureStartPoint.x - currentPosition.x);
	//CGFloat deltaY = fabsf(gestureStartPoint.y - currentPosition.y);

	// we got vertical swiping, baby!
	/*
	if(deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance) {
		
		//NSLog(@"swipe down!");
		if(popupIsAdded)
		{
			[UIView beginAnimations: nil context: @"some-identifier-used-by-a-delegate-if-set"];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration: 0.4f];
			
			CGRect tempFrame = popupView.frame;
			tempFrame.origin.y = 480.0f;
			self.popupView.frame = tempFrame;
			
			[UIView commitAnimations];
			
			popupIsAdded = false;
		}
	}
	*/
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1)
	{
		// call
		if(alertType == 0)
		{
			NSString *phone = [NSString stringWithFormat:@"tel://%@", self.selectedPoint.price];
			[phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//phone = [self.shuttle urlencode:phone];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
		}
		// directions
		if(alertType == 1)
		{
			NSString *latLong = [NSString stringWithFormat:@"%.8f,%.8f", self.selectedPoint.geoLocation.coordinate.latitude, self.selectedPoint.geoLocation.coordinate.longitude];
			//NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%@&z=14", self.selectedPoint.title, latLong];
			NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%.8f,%.8f&saddr=%.8f,%.8f&z=14", self.selectedPoint.geoLocation.coordinate.latitude, 
							 self.selectedPoint.geoLocation.coordinate.longitude, self.centerLocation.coordinate.latitude, self.centerLocation.coordinate.longitude];
			[latLong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//url = [self.shuttle urlencode:url];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
		// bing
		if(alertType == 2)
		{
			NSString *url = self.selectedPoint.url;
			[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
		// twitter
		if(alertType == 3)
		{
			NSString *url = [NSString stringWithFormat:@"http://www.twitter.com/%@", self.selectedPoint.author];
			[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
		// flickr
		if(alertType == 4)
		{
			//NSLog([NSString stringWithFormat:@"the image: %@", self.selectedPoint.giantimg]);
			NSString *url = self.selectedPoint.giantimg;
			[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
    [super dealloc];
}


@end
