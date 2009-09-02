#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Location : NSObject
{
    @private
        CLLocationCoordinate2D coordinate_;
        NSString *street_;
        NSString *postalCode_;
        NSString *city_;
        NSString *state_;
}

@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
