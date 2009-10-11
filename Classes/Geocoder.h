#import <CoreLocation/CoreLocation.h>
#import <ObjectiveLibxml2/ObjectiveLibxml2.h>

@class Geocoder;

// Protocol for the Geocoder Delegate
@protocol GeocoderDelegate <NSObject>
- (void)geocoder:(Geocoder *)geocoder didFailWithError:(NSError *)error;
- (void)geocoder:(Geocoder *)geocoder didFindCoordinate:(CLLocationCoordinate2D)coordinate;
@end

/**
 * Asynchronously returns the coordinates for a given location.
 *
 * Geocoder and GeocoderDelegate methods are meant to resemble MKReverseGeocoder 
 * and MKReverseGeocoderDelegate.
 */
@interface Geocoder : NSObject <ParserDelegate>
{
    @private
        id<GeocoderDelegate> delegate_;
        BOOL querying_;
        NSString *location_;
        CLLocationCoordinate2D coordinate_;
        NSOperationQueue *operationQueue_;
}

@property (nonatomic, assign) id<GeocoderDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isQuerying) BOOL querying;
@property (nonatomic, copy, readonly) NSString *location;

- (id)initWithLocation:(NSString *)location;
- (void)start;
- (void)cancel;

@end
