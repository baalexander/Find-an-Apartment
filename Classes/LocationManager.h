#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface LocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIAlertViewDelegate>
{
    @private
        CLLocationManager *locationManager_;
        CLLocation *userLocation_;
        id locationCaller_;
    
        MKReverseGeocoder *reverseGeocoder_;
    
        NSManagedObjectContext *mainObjectContext_;
        UIAlertView *alert_;
}

- (void)locateUser;

@property (nonatomic, retain, readonly) CLLocationManager *locationManager;
@property (nonatomic, retain, readonly) CLLocation *userLocation;
@property (nonatomic, retain) id locationCaller;

@property (nonatomic, retain, readonly) UIAlertView *alert;

@property (nonatomic, retain, readonly) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic, retain) NSManagedObjectContext *mainObjectContext;

@end
