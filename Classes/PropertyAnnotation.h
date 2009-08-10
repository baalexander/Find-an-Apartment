#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class PropertySummary;


@interface PropertyAnnotation : NSObject <MKAnnotation>
{
    @private
        CLLocationCoordinate2D coordinate_;
        NSString *address_;
        PropertySummary *summary_;
        
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) PropertySummary *summary;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
