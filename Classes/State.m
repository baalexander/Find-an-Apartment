#import "State.h"

#import "City.h"

@implementation State 

@dynamic name;
@dynamic abbreviation;
@dynamic cities;

- (NSString *)sectionCharacter
{
    return [[self name] substringToIndex:1];
}

@end
