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
}

- (void)centerMap;
- (NSArray *)geocodeFromCriteria:(PropertyCriteria *)criteria;
- (NSArray *)geocodeFromString:(NSString *)locationString;
- (void)geocodePropertyFromAddress:(NSString *)address;
- (void)geocodeProperties;

@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) MKMapView *mapView;

@end
