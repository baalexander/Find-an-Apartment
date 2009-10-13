#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

#import "Placemark.h"
#import "PropertyGeocoder.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate, PropertyGeocoderDelegate, MKMapViewDelegate>
{
    @private
        NSArray *properties_;
        NSMutableArray *geocodedProperties_;
        PropertyHistory *history_;
        PropertySummary *summary_;
        MKMapView *mapView_;
        BOOL isCancelled_;
        BOOL isFromFavorites_;
        NSInteger selectedIndex_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, assign) BOOL isFromFavorites;

@end
