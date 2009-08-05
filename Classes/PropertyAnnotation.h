#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface PropertyAnnotation : NSObject <MKAnnotation>
{
    @private
        CLLocationCoordinate2D coordinate_;
        NSString *address_;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *address;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
