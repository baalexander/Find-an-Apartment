//
//  ARCoordinate.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Modified by Tim Sears 11/2009.
//  Copyright 2009 Gravity Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARCoordinate : NSObject {
	double radialDistance;
	double inclination;
	double azimuth;
	
	bool isMultiple; // represents a group of locations
	bool viewSet;
	NSMutableArray *subLocations;
	
	NSString *theId;
	NSString *title;
	NSString *subtitle;
	
	NSString *price;
	NSString *summary;
}

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToCoordinate:(ARCoordinate *)otherCoordinate;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth;

@property bool isMultiple;
@property bool viewSet;
@property (nonatomic, retain) NSMutableArray *subLocations;
@property (nonatomic, retain) NSString *theId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *price;

@property (nonatomic) double radialDistance;
@property (nonatomic) double inclination;
@property (nonatomic) double azimuth;

@end
