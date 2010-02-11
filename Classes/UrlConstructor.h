#import <Foundation/Foundation.h>


@interface UrlConstructor : NSObject
{

}

- (NSString *)apiKey;
- (NSString *)version;
- (NSString *)deviceParams;
- (NSString *)rangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units;
- (NSString *)parameter:(NSString *)param withValue:(NSString *)value;
- (NSString *)parameter:(NSString *)param withNumericValue:(NSNumber *)value;

@end
