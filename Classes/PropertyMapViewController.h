#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "XmlParser.h"
#import "Placemark.h"
#import "PropertyHistory.h"
#import "PropertySummary.h"
#import "PropertyDetailsViewController.h"


@interface PropertyMapViewController : UIViewController <PropertyDetailsDelegate, ParserDelegate, MKMapViewDelegate>
{
    @private
        PropertyHistory *history_;
        NSArray *summaries_;
        PropertySummary *summary_;
        MKMapView *mapView_;
        NSOperationQueue *operationQueue_;
        Placemark *placemark_;
        CLLocationCoordinate2D maxPoint_;
        CLLocationCoordinate2D minPoint_;
        BOOL isCancelled_;
        BOOL isFromFavorites_;
        NSInteger summaryIndex_;
        NSInteger selectedIndex_;
        BOOL shouldAddButtonToAnnotation_;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) PropertyHistory *history;
@property (nonatomic, retain) PropertySummary *summary;
@property (nonatomic, assign) BOOL isFromFavorites;
@property (nonatomic, assign) BOOL shouldAddButtonToAnnotation;

@end
