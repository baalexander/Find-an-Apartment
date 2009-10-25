#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Geocoder.h"
#import "PropertySummary.h"


@interface PropertyDetailsMapViewController : UIViewController <GeocoderDelegate, MKMapViewDelegate>
{
    @private
        MKMapView *mapView_;
        Geocoder *geocoder_;
        BOOL geocoding_;
        PropertySummary *property_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)mapProperty:(PropertySummary *)property;
- (IBAction)loadInGoogleMaps:(id)sender;

@end
