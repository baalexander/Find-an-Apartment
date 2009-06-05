#import <Foundation/Foundation.h>

#import "PropertyCriteria.h"


@interface PropertyUrlConstructor : NSObject
{
    @private
        PropertyCriteria *criteria_;
}

- (NSURL *)urlFromCriteria:(PropertyCriteria *)criteria;

@end
