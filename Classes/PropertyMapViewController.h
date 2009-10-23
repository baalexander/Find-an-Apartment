#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PropertyCriteria.h"
#import "PropertyResultsDataSource.h"
#import "PropertyResultsDelegate.h"
#import "Geocoder.h"


@interface PropertyMapViewController : UIViewController <GeocoderDelegate, MKMapViewDelegate>
{
    @private
        MKMapView *mapView_;
        id <PropertyResultsDataSource> propertyDataSource_;
        id <PropertyResultsDelegate> propertyDelegate_;
        PropertyCriteria *criteria_;
        Geocoder *geocoder_;
        BOOL geocoding_;
        BOOL centered_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDataSource> propertyDataSource;
@property (nonatomic, assign) IBOutlet id <PropertyResultsDelegate> propertyDelegate;

- (void)placeGeocodedPropertyOnMap:(PropertySummary *)property withIndex:(NSInteger)index;
- (void)centerOnCriteria:(PropertyCriteria *)criteria;
- (void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate;

@end
