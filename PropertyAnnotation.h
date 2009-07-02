#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface PropertyAnnotation : NSObject <MKAnnotation>
{
    @private
    CLLocationCoordinate2D coordinate_;
    NSString *title_;
    NSString *subtitle_;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
