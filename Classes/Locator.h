#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Location.h"

@class Locator;

//Protocol for the locator delegate to implement for location callbacks
@protocol LocatorDelegate <NSObject>
//Found location and populates container object
- (void)locator:(Locator *)locator setLocation:(Location *)location;
@end


@interface Locator : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIAlertViewDelegate>
{
    @private
        CLLocationManager *locationManager_;
        CLLocation *userLocation_;
        id<LocatorDelegate> delegate_;
        MKReverseGeocoder *reverseGeocoder_;
        UIAlertView *alert_;    
        BOOL didCancel_;
}

@property (nonatomic, assign) id<LocatorDelegate> delegate;

+ (Locator *)sharedInstance;
- (void)locate;

@end
