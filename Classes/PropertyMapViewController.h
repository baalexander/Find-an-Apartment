#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "Placemark.h"
#import "PropertyGeocoder.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetailsViewController.h"
#import "PropertyDataSource.h"
#import "Geocoder.h"


@interface PropertyMapViewController : UIViewController <GeocoderDelegate, PropertyGeocoderDelegate, MKMapViewDelegate>
{
    @private
        NSArray *properties_;
        NSMutableArray *geocodedProperties_;
        PropertyHistory *history_;
        PropertySummary *summary_;
        MKMapView *mapView_;
        BOOL isCancelled_;
        id <PropertyDataSource> propertyDataSource_;
        Geocoder *geocoder_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, assign) IBOutlet id <PropertyDataSource> propertyDataSource;

- (void)placeGeocodedPropertyOnMap:(PropertySummary *)property withIndex:(NSInteger)index;
- (void)centerOnCriteria:(PropertyCriteria *)criteria;
- (void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate;

@end
