#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PropertyHistory.h"
#import "PropertyGeocodeParser.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate, ParserDelegate, MKMapViewDelegate>
{
    @private
        PropertyHistory *history_;    
        MKMapView *mapView_;
        NSOperationQueue *operationQueue_;
        NSMutableDictionary *placemark_;
        NSUInteger summaryCount_;
        CLLocationCoordinate2D maxPoint_;
        CLLocationCoordinate2D minPoint_;
        BOOL firstTime_;
}

- (void)geocodeProperties;

@property (nonatomic, retain) PropertyHistory *history;

@end
