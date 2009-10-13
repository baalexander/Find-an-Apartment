#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Placemark.h"


@interface PropertyAnnotation : NSObject <MKAnnotation>
{
    @private
        Placemark *placemark_;
        NSInteger index_;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) Placemark *placemark;
@property (nonatomic, assign) NSInteger index;

- (id)initWithPlacemark:(Placemark *)placemark;

@end
