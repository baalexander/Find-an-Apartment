#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Placemark : NSObject
{
    @private
        NSString *address_;
        CLLocationCoordinate2D coordinate_;
        double north_;
        double east_;
        double south_;
        double west_;
}

@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) double north;
@property (nonatomic, assign) double east;
@property (nonatomic, assign) double south;
@property (nonatomic, assign) double west;

@end
