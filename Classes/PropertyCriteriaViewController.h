#import <UIKit/UIKit.h>

#import "CriteriaViewController.h"
#import "PropertyCriteria.h"
#import "Location.h"


@interface PropertyCriteriaViewController : CriteriaViewController
{
    @private
        NSManagedObjectContext *propertyObjectContext_;
        PropertyCriteria *criteria_;
}

@property (nonatomic, retain) NSManagedObjectContext *propertyObjectContext;

@end
