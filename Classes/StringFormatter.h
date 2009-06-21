#import <Foundation/Foundation.h>


@interface StringFormatter : NSObject
{

}

+ (NSString *)formatNumber:(NSNumber *)number;
+ (NSString *)formatCurrency:(NSNumber *)currency;
+ (NSString *)formatRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units;
+ (NSString *)formatCurrencyRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max;

@end
