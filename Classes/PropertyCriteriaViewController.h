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
        
        State *state_;
        CityOrPostalCode *city_;
        CityOrPostalCode *postalCode_;
        CLLocationCoordinate2D coordinates_;
        PropertyCriteria *criteria_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;

@property (nonatomic, retain) State *state;
@property (nonatomic, retain) CityOrPostalCode *city;
@property (nonatomic, retain) CityOrPostalCode *postalCode;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, retain) PropertyCriteria *criteria;

@end
