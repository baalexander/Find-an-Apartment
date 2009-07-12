#import "StringFormatter.h"


@implementation StringFormatter

+ (NSString *)formatNumber:(NSNumber *)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    //Formats number or 0 if number is nil
    NSString *formattedNumber;
    if (number == nil)
    {
        NSNumber *zeroNumber = [[NSNumber alloc] initWithFloat:0];
        formattedNumber = [formatter stringFromNumber:zeroNumber];
        [zeroNumber release];
    }
    else
    {
        formattedNumber = [formatter stringFromNumber:number];
    }

    [formatter release];
    
    return formattedNumber;
}

+ (NSString *)formatCurrency:(NSNumber *)currency
{    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMinimumFractionDigits:0];

    //Formats currency or 0 if currency is nil
    NSString *formattedCurrency;
    if (currency == nil)
    {
        NSNumber *zeroNumber = [[NSNumber alloc] initWithFloat:0];
        formattedCurrency = [formatter stringFromNumber:zeroNumber];
        [zeroNumber release];
    }
    else
    {
        formattedCurrency = [formatter stringFromNumber:currency];
    }

    [formatter release];

    return formattedCurrency;
}

//Returns range in the following formats depending on what parameters are sent:
//  min - max units
//  0 - max units
//  min+ units
+ (NSString *)formatRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max withUnits:(NSString *)units
{
    //Placeholders
    if (units == nil)
    {
        units = @"";
    }
    else
    {
        units = [NSString stringWithFormat:@" %@", units];
    }
    
    //Formates a zero number for replacing empty values in range
    NSNumber *zeroNumber = [[NSNumber alloc] initWithInteger:0];
    NSString *formattedZero = [StringFormatter formatNumber:zeroNumber];
    [zeroNumber release];
    
    //Formats min and max numbers
    NSString *formattedMin = [StringFormatter formatNumber:min];
    NSString *formattedMax = [StringFormatter formatNumber:max];
    
    //Returns range based on which values were provided
    if (min == nil && max == nil)
    {
        return [NSString stringWithFormat:@"%@+%@", formattedZero, units];
    }
    else if (min == nil)
    {
        return [NSString stringWithFormat:@"%@ - %@%@", formattedZero, formattedMax, units];
    }
    else if (max == nil)
    {
        return [NSString stringWithFormat:@"%@+%@", formattedMin, units];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ - %@%@", formattedMin, formattedMax, units];
    }
}

+ (NSString *)formatCurrencyRangeWithMin:(NSNumber *)min withMax:(NSNumber *)max
{
    //Formates a zero number for replacing empty values in range
    NSNumber *zeroNumber = [[NSNumber alloc] initWithInteger:0];
    NSString *formattedZero = [StringFormatter formatCurrency:zeroNumber];
    [zeroNumber release];
    
    //Formats min and max numbers
    NSString *formattedMin = [StringFormatter formatCurrency:min];
    NSString *formattedMax = [StringFormatter formatCurrency:max];
    
    //Returns range based on which values were provided
    if (min == nil && max == nil)
    {
        return [NSString stringWithFormat:@"%@+", formattedZero];
    }
    else if (min == nil)
    {
        return [NSString stringWithFormat:@"%@ - %@", formattedZero, formattedMax];
    }
    else if (max == nil)
    {
        return [NSString stringWithFormat:@"%@+", formattedMin];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ - %@", formattedMin, formattedMax];
    }
}


@end
