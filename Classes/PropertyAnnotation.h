#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Placemark.h"
#import "PropertySummary.h"


@interface PropertyAnnotation : NSObject <MKAnnotation>
{
    @private
        Placemark *placemark_;
        PropertySummary *summary_;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Placemark *placemark;
@property (nonatomic, retain) PropertySummary *summary;

- (id)initWithPlacemark:(Placemark *)placemark andSummary:(PropertySummary *)summary;

@end
