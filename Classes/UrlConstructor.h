#import <Foundation/Foundation.h>


@interface UrlConstructor : NSObject
{

}

- (NSString *)deviceParams;
- (NSString *)rangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units;

@end
