#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Placemark.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyGeocodeParser.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate, ParserDelegate, MKMapViewDelegate>
{
    @private
        PropertyHistory *history_;
        PropertySummary *summary_;
        MKMapView *mapView_;
        NSOperationQueue *operationQueue_;
        Placemark *placemark_;
        NSUInteger summaryCount_;
        CLLocationCoordinate2D maxPoint_;
        CLLocationCoordinate2D minPoint_;
        BOOL firstTime_;
}

@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) PropertySummary *summary;

@end
