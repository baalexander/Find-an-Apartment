#import <Foundation/Foundation.h>
#import "ARGeoCoordinate.h"
#import <CoreLocation/CoreLocation.h>

@interface PropertyArGeoCoordinate : ARGeoCoordinate
{
    NSMutableArray *subLocations_;
    NSString *price_;
    NSString *summary_;
    BOOL isMultiple_;
    BOOL viewSet_;
}

+ (PropertyArGeoCoordinate *)coordinateWithLocation:(CLLocation *)location;
+ (PropertyArGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;

@property (nonatomic, retain) NSMutableArray *subLocations;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, assign) BOOL isMultiple;
@property (nonatomic, assign) BOOL viewSet;

@end
