#import <Foundation/Foundation.h>

#import "UrlConstructor.h"
#import "MortgageCriteria.h"


@interface MortgageUrlConstructor : UrlConstructor
{
    @private
        MortgageCriteria *criteria_;
}

- (NSURL *)urlFromCriteria:(MortgageCriteria *)criteria;

@end
