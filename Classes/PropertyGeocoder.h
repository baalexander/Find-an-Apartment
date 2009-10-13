#import "PropertySummary.h"
#import "Geocoder.h"

@class PropertyGeocoder;

/**
 * Delegate receives immediate feedback when a propery has been geocoded or an 
 * error occurs.
 */
@protocol PropertyGeocoderDelegate <NSObject>
- (void)propertyGeocoder:(PropertyGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)propertyGeocoder:(PropertyGeocoder *)geocoder didFindProperty:(PropertySummary *)property;
@end

/**
 * Singleton geocodes set of properties and saves in Core Data. The class acts 
 * as a singleton so the geocoding process won't belong to single view
 * controller. This will allow for switching between map, list, and some day
 * augmented reality views while persisting the geocoding.
 */
@interface PropertyGeocoder : NSObject <GeocoderDelegate>
{
    @private
        id <PropertyGeocoderDelegate> delegate_;
        NSArray *properties_;
        BOOL querying_;
        Geocoder *geocoder_;
        PropertySummary *property_;
}

/**
 * Updates delegate with successfully geocoded properties and any errors 
 * encountered.
 */
@property (nonatomic, assign) id <PropertyGeocoderDelegate> delegate;

/**
 * Set of properties to geocode. Already geocoded properties in the set will be 
 * ignored. Setting summaries will cancel the currently running geocode process.
 */
@property (nonatomic, retain) NSArray *properties;

/**
 * Tells if currently geocoding or not.
 */
@property (nonatomic, assign, readonly, getter=isQuerying) BOOL querying;

/**
 * Use this function to get an instance of the class. Do not init.
 */
+ (PropertyGeocoder *)sharedInstance;

/**
 * Returns set of properties that have been geocoded.
 */
- (NSSet *)geocodedProperties;

/**
 * Starts geocoding the properties. Should set property summaries before
 * calling.
 */
- (void)start;

/**
 * Cancels the property geocoding process.
 */
- (void)cancel;

@end
