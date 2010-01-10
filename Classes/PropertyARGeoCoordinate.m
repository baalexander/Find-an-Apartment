//
//  PropertyARGeoCoordinate.m
//  Find an Apartment
//
//  Created by Timothy Sears on 1/8/10.
//  Copyright 2010 Alexander Mobile. All rights reserved.
//

#import "PropertyARGeoCoordinate.h"


@implementation PropertyARGeoCoordinate

@synthesize isMultiple;
@synthesize viewSet;
@synthesize subLocations;
@synthesize theId;
@synthesize summary;
@synthesize price;

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
	
	double nA =	pow ( sin(nDLat/2), 2 ) +
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
    if (longitudinalDifference > 0) return azimuth;
    else if (longitudinalDifference < 0) return azimuth + M_PI;
    else if (latitudinalDifference < 0) return M_PI;
    return 0.0f;
}

- (void)calibrateUsingOrigin:(CLLocation *)origin {
	self.radialDistance = CalculateDistance(origin.coordinate.latitude, origin.coordinate.longitude, self.geoLocation.coordinate.latitude, self.geoLocation.coordinate.longitude);
	//self.inclination = 0.0; // TODO: Make with altitude.
	self.azimuth = CalculateAngle(origin.coordinate.latitude, origin.coordinate.longitude, self.geoLocation.coordinate.latitude, self.geoLocation.coordinate.longitude);
}


+ (PropertyARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location {
	PropertyARGeoCoordinate *newCoordinate = [[PropertyARGeoCoordinate alloc] init];
	newCoordinate.geoLocation = location;
	
	newCoordinate.title = @"GEO";
	
	return [newCoordinate autorelease];
}

+ (PropertyARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin {
	PropertyARGeoCoordinate *newCoordinate = [PropertyARGeoCoordinate coordinateWithLocation:location];
	
	[newCoordinate calibrateUsingOrigin:origin];
	
	return newCoordinate;
}

@end
