#import "City.h"

#import "State.h"

@implementation City 

@dynamic name;
@dynamic state;

- (NSString *)sectionCharacter
{
    return [[self name] substringToIndex:1];
}

@end
