//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Modified by Tim Sears 11/2009.
//  Copyright 2009 Gravity Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"

@protocol ARViewDelegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;
- (void)onARControllerClose;

@end

@interface ARViewController : UIViewController <UIAccelerometerDelegate, CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
	ARCoordinate *centerCoordinate;
	NSRange *widthViewportRange;
	NSRange *heightViewportRange;
	id delegate;

	NSArray *locationItems;
	NSMutableArray *locationViews;
	NSMutableArray *locationItemsInView;
	NSMutableArray *baseItems;
	CLLocation *centerLocation;
	UIImageView *popupView;
	UIView *contentView;
	UIView *locationLayerView;
	CGPoint gestureStartPoint;
	ARGeoCoordinate *selectedPoint;
	ARGeoCoordinate *selectedSubPoint;
	int contentType;
	UILabel *bottomView;
	UIImagePickerController *camera;
	UIActivityIndicatorView *progressView;
	
	bool popupIsAdded;
	bool updatedLocations;
	bool shouldChangeHighlight;
	bool recalibrateProximity;
	double minDistance; // used for calculating inclination
	int currentPage; // current page selected of subitems
}

- (void)startListening;
- (void)updateLocations;
- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate;
- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;
- (bool)isNearCoordinate:(ARGeoCoordinate *)coord newCoordinate:(ARGeoCoordinate *)newCoord;
- (void)updateProximityLocations;
- (void)makePanel;

@property (nonatomic, assign) id delegate;

@property (retain) ARCoordinate *centerCoordinate;
@property (nonatomic, retain) NSArray *locationItems;
@property (nonatomic, copy) NSMutableArray *locationViews;
@property (nonatomic, retain) NSMutableArray *locationItemsInView;
@property (nonatomic, retain) NSMutableArray *baseItems;
@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *centerLocation;
@property (nonatomic, retain) UIImageView *popupView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *locationLayerView;
@property (nonatomic, retain) ARGeoCoordinate *selectedPoint;
@property (nonatomic, retain) ARGeoCoordinate *selectedSubPoint;
@property (nonatomic, retain) NSString *currentRadius;
@property (nonatomic, retain) UILabel *bottomView;
@property (nonatomic, retain) UIImagePickerController *camera;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;

@property bool popupIsAdded;
@property int contentType;
@property bool updatedLocations;
@property bool shouldChangeHighlight;
@property bool recalibrateProximity;
@property double minDistance;
@property int currentPage;
@property CGPoint gestureStartPoint;

@end
