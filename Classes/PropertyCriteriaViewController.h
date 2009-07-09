#import <UIKit/UIKit.h>

#import "State.h"
#import "CityOrPostalCode.h"
#import "PropertyCriteria.h"


@class InputRangeCell;
@class InputSimpleCell;

@interface PropertyCriteriaViewController : UITableViewController <UITextFieldDelegate>
{
    @private
        NSManagedObjectContext *propertyObjectContext_;
        
        State *state_;
        CityOrPostalCode *city_;
        CityOrPostalCode *postalCode_;
        NSString *coordinates_;
        PropertyCriteria *criteria_;
        
        UITextField *currentTextField_;
        NSInteger selectedRow_;
        NSArray *rowIds_;
        
        IBOutlet InputRangeCell *inputRangeCell_;
        IBOutlet InputSimpleCell *inputSimpleCell_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;

@property (nonatomic, retain) State *state;
@property (nonatomic, retain) CityOrPostalCode *city;
@property (nonatomic, retain) CityOrPostalCode *postalCode;
@property (nonatomic, copy) NSString *coordinates;
@property (nonatomic, retain) PropertyCriteria *criteria;

@property (nonatomic, retain) InputRangeCell *inputRangeCell;
@property (nonatomic, retain) InputSimpleCell *inputSimpleCell;

@end
