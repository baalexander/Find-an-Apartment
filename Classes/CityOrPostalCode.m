#import "CityOrPostalCode.h"

#import "State.h"

@implementation CityOrPostalCode 

@dynamic value;
@dynamic isCity;
@dynamic state;

- (NSString *)sectionCharacter {
    return [[self value] substringToIndex:1];
}


@end
