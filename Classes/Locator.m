#import "Locator.h"

#import "Location.h"


@interface Locator ()
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, assign) BOOL didCancel;
- (void)alertErrorWithTitle:(NSString *)title withMessage:(NSString *)message;
@end


@implementation Locator

@synthesize locationManager = locationManager_;
@synthesize userLocation = userLocation_;
@synthesize delegate = delegate_;
@synthesize alert = alert_;
@synthesize reverseGeocoder = reverseGeocoder_;
@synthesize didCancel = didCancel_;


#pragma mark -
#pragma mark Locator

static Locator *instance_ = NULL;

+ (Locator *)sharedInstance
{
    @synchronized(self)
    {
        if (instance_ == NULL)
        {
            instance_ = [[self alloc] init];
        }
    }
    
    return (instance_);
}


- (void)dealloc
{
    [locationManager_ release];
    [userLocation_ release];
    [reverseGeocoder_ release];
    [alert_ release];
    
    [super dealloc];
}

- (void)locate
{
    [self setDidCancel:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"Finding your location" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [self setAlert:alert];
    [alert release];
    [[self alert] show];
    
    if(locationManager_ == nil)
    {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self setLocationManager:locationManager];
        [locationManager release];
    }
    
    [[self locationManager] startUpdatingLocation];
}

- (void)alertErrorWithTitle:(NSString *)title withMessage:(NSString *)message
{
    [[self alert] dismissWithClickedButtonIndex:0 animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self setAlert:alert];
    [alert release];
    [[self alert] show];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// We only want a single location, so stop updating
	[[self locationManager] stopUpdatingLocation];
    
	if (signbit([newLocation horizontalAccuracy]))
    {
		// Negative accuracy means an invalid or unavailable measurement
		DebugLog(@"Invalid or unavailable measurement");
        return;
	}
    [self setUserLocation:newLocation];
    
    MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:[newLocation coordinate]];
    [reverseGeocoder setDelegate:self];
    [self setReverseGeocoder:reverseGeocoder];
    [reverseGeocoder release];
    [[self reverseGeocoder] start];    	
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DebugLog(@"Error domain: %@\nError code: %d\nError Description: %@", [error domain], [error code], [error localizedDescription]);

    NSString *errorMessage = @"Error getting your location.";

     //Core location related errors
	if ([error domain] == kCLErrorDomain)
    {    
		switch ([error code]) 
        {
            // This error code is usually returned whenever user taps "Don't Allow" in response to
            // being told your app wants to access the current location. Once this happens, you cannot
            // attempt to get the location again until the app has quit and relaunched.
            //
            // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
            // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            //
			case kCLErrorDenied:
                errorMessage = @"Not allowed to access your location.";
				break;
                
            // This error code is usually returned whenever the device has no data or WiFi connectivity,
            // or when the location cannot be determined for some other reason.
            //
            // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
            //
			case kCLErrorLocationUnknown:
                errorMessage = @"Could not determine your location.";
				break;
		}
	} 
    
    [self alertErrorWithTitle:nil withMessage:errorMessage];
}


#pragma mark -
#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    DebugLog(@"Reverse geocoder error: %@", [error localizedDescription]);
    
    [self alertErrorWithTitle:nil withMessage:@"Could not determine your location."];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    //If cancelled before reverse geocoder returned, then exit
    if ([self didCancel])
    {
        return;
    }
    
    //Populates Location with Placemark data
    Location *location = [[Location alloc] init];
    [location setCoordinate:[[self userLocation] coordinate]];
    if ([placemark postalCode] != nil)
    {
        [location setPostalCode:[placemark postalCode]];
    }
    if ([placemark locality] != nil)
    {
        [location setCity:[placemark locality]];
    }    
    if ([placemark administrativeArea] != nil)
    {
        [location setState:[placemark administrativeArea]];
    }
    
    //Subthoroughfare is the street number, thoroughfare is the street
    if ([placemark subThoroughfare] != nil && [placemark thoroughfare] != nil)
    {
        NSString *street = [[NSString alloc] initWithFormat:@"%@ %@", [placemark subThoroughfare], [placemark thoroughfare]];
        [location setStreet:street];
        [street release];
    }
    else if ([placemark thoroughfare] != nil)
    {
        [location setStreet:[placemark thoroughfare]];
    }
    
    //Send Location to delegate
    [[self delegate] locator:self setLocation:location];
    [location release];

    //Dismiss the "Please wait..." alert
    [[self alert] dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setDidCancel:YES];
    
    [[self locationManager] stopUpdatingLocation];
    [[self reverseGeocoder] cancel];
}

@end
