#import "State.h"

#import "CityOrPostalCode.h"

@implementation State 

@dynamic name;
@dynamic abbreviation;
@dynamic citiesAndPostalCodes;

- (NSString *)sectionCharacter {
    return [[self name] substringToIndex:1];
}


@end
