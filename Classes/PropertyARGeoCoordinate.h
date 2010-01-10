//
//  PropertyARGeoCoordinate.h
//  Find an Apartment
//
//  Created by Timothy Sears on 1/8/10.
//  Copyright 2010 Alexander Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARGeoCoordinate.h"
#import <CoreLocation/CoreLocation.h>

@interface PropertyARGeoCoordinate : ARGeoCoordinate {

	bool isMultiple; // represents a group of locations
	bool viewSet;
	NSMutableArray *subLocations;
	NSString *theId;
	NSString *price;
	NSString *summary;
}

+ (PropertyARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location;
+ (PropertyARGeoCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;

@property bool isMultiple;
@property bool viewSet;
@property (nonatomic, retain) NSMutableArray *subLocations;
@property (nonatomic, retain) NSString *theId;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *price;


@end
