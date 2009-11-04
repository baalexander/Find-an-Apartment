#import <UIKit/UIKit.h>
#import "ARGeoViewController.h"
#import "PropertySummary.h"


@interface PropertyArViewController : ARGeoViewController <ARViewDelegate>
{

}

- (void)addGeocodedProperty:(PropertySummary *)property atIndex:(NSInteger)index;

@end
