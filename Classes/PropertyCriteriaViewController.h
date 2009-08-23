#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "CriteriaViewController.h"
#import "State.h"
#import "CityOrPostalCode.h"
#import "PropertyCriteria.h"


@interface PropertyCriteriaViewController : CriteriaViewController
{
    @private
        NSManagedObjectContext *propertyObjectContext_;
        
        NSString *state_;
        NSString *city_;
        NSString *postalCode_;
        CLLocationCoordinate2D coordinates_;
        PropertyCriteria *criteria_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;

@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, retain) PropertyCriteria *criteria;

@end
