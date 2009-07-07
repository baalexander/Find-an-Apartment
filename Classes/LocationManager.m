#import "LocationManager.h"

#import "PropertyCriteria.h"
#import "PropertyStatesViewController.h"
#import "PropertyCitiesViewController.h"


@interface LocationManager ()

@property (nonatomic, retain, readwrite) CLLocationManager *locationManager;
@property (nonatomic, retain, readwrite) CLLocation *userLocation;
@property (nonatomic, retain, readwrite) UIAlertView *alert;
@property (nonatomic, retain, readwrite) MKReverseGeocoder *reverseGeocoder;

@end


@implementation LocationManager

@synthesize locationManager = locationManager_;
@synthesize userLocation = userLocation_;
@synthesize locationCaller = locationCaller_;
@synthesize propertyObjectContext = propertyObjectContext_;
@synthesize alert = alert_;
@synthesize reverseGeocoder = reverseGeocoder_;

- (void)locateUser
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"Finding your location" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [self setAlert:alert];
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


#pragma mark -
#pragma mark Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{	
	// We only want a single location, so stop updating
	[[self locationManager] stopUpdatingLocation];
    
	if (signbit([newLocation horizontalAccuracy]))
    {
		// Negative accuracy means an invalid or unavailable measurement
		NSLog(@"Invalid or unavailable measurement");
        return;
	}
    [self setUserLocation:newLocation];
    
    MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:[newLocation coordinate]];
    [reverseGeocoder setDelegate:self];
    [self setReverseGeocoder:reverseGeocoder];
    [[self reverseGeocoder] start];    	
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSMutableString *errorString = [[NSMutableString alloc] init];
    
	if ([error domain] == kCLErrorDomain) {
        
		// We handle CoreLocation-related errors here
        
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
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
                
                // This error code is usually returned whenever the device has no data or WiFi connectivity,
                // or when the location cannot be determined for some other reason.
                //
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
                //
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
                
                // We shouldn't ever get an unknown error code, but just in case...
                //
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} 
    else 
    {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
    
    NSLog(@"Error getting location: %@", errorString);
    [errorString release];
}


#pragma mark -
#pragma mark Reverse Geocoder

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"Reverse geocoder error: %@", error);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    PropertyCriteria *criteria = [NSEntityDescription insertNewObjectForEntityForName:@"PropertyCriteria" 
                                                               inManagedObjectContext:[self propertyObjectContext]];
    CLLocationCoordinate2D coords = [[self userLocation] coordinate];
    NSString *coordinates = [[NSString alloc] initWithFormat:@"%f,%f", coords.latitude, coords.longitude]; 
    [criteria setCoordinates:coordinates];
    [coordinates release];
    
    [criteria setState:[placemark administrativeArea]];
    [criteria setPostalCode:[placemark postalCode]];
    [criteria setCity:[placemark locality]];
    [[self alert] dismissWithClickedButtonIndex:0 animated:YES];
    
    if([[self locationCaller] isKindOfClass:[PropertyStatesViewController class]])
    {
        PropertyStatesViewController *caller = (PropertyStatesViewController *)[self locationCaller];
        [caller useCriteria:criteria];
    }
    
    else
    {
        PropertyCitiesViewController *caller = (PropertyCitiesViewController *)[self locationCaller];
        [caller useCriteria:criteria];
    }
}


#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertViewCancel:(UIAlertView *)alertView
{
    [[self locationManager] stopUpdatingLocation];
    [[self reverseGeocoder] cancel];
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [locationManager_ release];
    [userLocation_ release];
    [locationCaller_ release];
    [reverseGeocoder_ release];
    [propertyObjectContext_ release];
    [alert_ release];
    
    [super dealloc];
}

@end
