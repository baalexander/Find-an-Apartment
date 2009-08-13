#import "XmlElement.h"


@implementation XmlElement

@synthesize name = name_;
@synthesize value = value_;
@synthesize attributes = attributes_;

- (id)init
{    
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [name_ release];
    [value_ release];
    [attributes_ release];
    
    [super dealloc];
}

@end
