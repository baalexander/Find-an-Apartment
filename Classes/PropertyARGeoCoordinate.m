#import "PropertyArGeoCoordinate.h"


@implementation PropertyArGeoCoordinate

@synthesize subLocations = subLocations_;
@synthesize summary = summary_;
@synthesize price = price_;
@synthesize index = index_;
@synthesize isMultiple = isMultiple_;
@synthesize viewSet = viewSet_;

- (void)dealloc
{
    [subLocations_ release];
    [summary_ release];
    [price_ release];
    
    [super dealloc];
}

+ (PropertyArGeoCoordinate *)coordinateWithLocation:(CLLocation *)location
{
    PropertyArGeoCoordinate *coordinate = [[[PropertyArGeoCoordinate alloc] init] autorelease];
    [coordinate setGeoLocation:location];
    [coordinate setTitle:@"GEO"];
    
    return coordinate;
}

+ (PropertyArGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin
{
    PropertyArGeoCoordinate *coordinate = [PropertyArGeoCoordinate coordinateWithLocation:location];
    [coordinate calibrateUsingOrigin:origin];
    
    return coordinate;
}

double ToRad( double nVal )
{
    return nVal * (M_PI/180);
}

double CalculateDistance( double nLat1, double nLon1, double nLat2, double nLon2 )
{
    double nRadius = 6371; // Earth's radius in Kilometers
    
    // Get the difference between our two points then convert the difference into radians
    double nDLat = ToRad(nLat2 - nLat1);  
    double nDLon = ToRad(nLon2 - nLon1); 
    
    nLat1 =  ToRad(nLat1);
    nLat2 =  ToRad(nLat2);
    
    double nA =    pow ( sin(nDLat/2), 2 ) +
    cos(nLat1) * cos(nLat2) * 
    pow ( sin(nDLon/2), 2 );
    
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    
    return nD; // Return our calculated distance
}

float CalculateAngle(float nLat1, float nLon1, float nLat2, float nLon2)
{    
    float longitudinalDifference = nLon2 - nLon1;
    float latitudinalDifference = nLat2 - nLat1;
    float azimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
    if (longitudinalDifference > 0)
    {
        return azimuth;
    }
    else if (longitudinalDifference < 0)
    {
        return azimuth + M_PI;
    }
    else if (latitudinalDifference < 0)
    {
        return M_PI;
    }

    return 0.0f;
}

- (void)calibrateUsingOrigin:(CLLocation *)origin
{
    [self setRadialDistance:CalculateDistance([origin coordinate].latitude, [origin coordinate].longitude, [[self geoLocation] coordinate].latitude, [[self geoLocation] coordinate].longitude)];
    //self.inclination = 0.0; // TODO: Make with altitude.
    [self setAzimuth:CalculateAngle([origin coordinate].latitude, [origin coordinate].longitude, [[self geoLocation] coordinate].latitude, [[self geoLocation] coordinate].longitude)];
}

@end
