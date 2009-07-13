#import <Foundation/Foundation.h>

#import "UrlConstructor.h"
#import "PropertyCriteria.h"


@interface PropertyUrlConstructor : UrlConstructor
{
    @private
        PropertyCriteria *criteria_;
}

- (NSURL *)urlFromCriteria:(PropertyCriteria *)criteria;

@end
