#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PropertyHistory.h"
#import "PropertyDetailsViewController.h"
@class PropertyCriteria;


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate, MKMapViewDelegate>
{
    @private
        PropertyHistory *history_;
        NSString *address_;
        MKMapView *mapView_;
        NSArray *summaries_;
        NSMutableDictionary *geocodedResponses_;
        BOOL singleAddress_;
        double minLat_;
        double maxLat_;
        double minLon_;
        double maxLon_;
    
}

- (void)centerMap;
- (void)geocodeFromCriteria:(PropertyCriteria *)criteria;
- (void)geocodeFromLocation:(NSString *)locationString;
- (void)geocodePropertyFromAddress:(NSString *)address;
- (void)geocodeProperties;
- (void)parseGeocodingResponseForConnection:(NSURLConnection *)connection WithAddress:(NSString *)address;
- (void)updateMinMaxWithCoordinates:(CLLocationCoordinate2D)coordinates;

@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSArray *summaries;
@property (nonatomic, retain) NSMutableDictionary *geocodedResponses;
@property BOOL singleAddress;
@property double minLat;
@property double maxLat;
@property double minLon;
@property double maxLon;

@end
