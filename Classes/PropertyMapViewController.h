#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PropertyHistory.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate>
{
    @private
        PropertyHistory *history_;
        MKMapView *mapView_;
}

- (void)centerMap;

@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) MKMapView *mapView;

@end
