#import "LocationCell.h"


@implementation LocationCell

@synthesize addressLine1 = addressLine1_;
@synthesize addressLine2 = addressLine2_;


#pragma mark -
#pragma mark LocationCell

- (void)dealloc
{
    [addressLine1_ release];
    [addressLine2_ release];
    
    [super dealloc];
}

+ (NSArray *)parseLocation:(NSString *)unparsedLocation
{
	//Holds address as two parts: street and city,state,zip
	NSMutableArray *locationArray = [NSMutableArray array];
	NSArray *locationComponents = [unparsedLocation componentsSeparatedByString:@","];
	//If at least two parts of the location, breaks up into street and city,state,zip
	if ([locationComponents count] > 1)
	{
		NSMutableString *mutableLocation = [[NSMutableString alloc] init];
		BOOL firstTime = YES;
		for (NSString *locationComponent in locationComponents)
		{
			//Ignores first result (could be street)
			if (firstTime)
			{
				firstTime = NO;
				//Determines if street specified by checking if first component begins with a number
				NSRange numberRange = [locationComponent rangeOfString:@" "];
				if (numberRange.location != NSNotFound)
				{
					NSString *strNumber = [locationComponent substringToIndex:numberRange.location];
					NSInteger number = [strNumber integerValue];
					if (number > 0)
					{
						[locationArray addObject:locationComponent];
						continue;
					}
				}
			}
			
			//Ignores USA
			if ([locationComponent rangeOfString:@"USA"].location != NSNotFound)
			{
				continue;
			}
			
			[mutableLocation appendString:[locationComponent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			[mutableLocation appendString:@", "];
		}
		
		NSString *cityStateZip = [mutableLocation substringToIndex:[mutableLocation length]-2];
		[mutableLocation release];
		[locationArray addObject:cityStateZip];
	}
	//Only one part in location, sets as-is
	else
	{
		[locationArray addObject:unparsedLocation];
	}
	
	return locationArray;
}

- (void)setLocation:(NSString *)location
{
    NSArray *locationArray = [LocationCell parseLocation:location];
    
    if ([locationArray count] >= 2)
    {
        [[self addressLine1] setText:[locationArray objectAtIndex:0]];
        [[self addressLine2] setText:[locationArray objectAtIndex:1]];
    }
    else if ([locationArray count] == 1)
    {
        [[self addressLine1] setText:@"No street provided"];
        [[self addressLine2] setText:[locationArray objectAtIndex:1]];
    }
    else
    {
        [[self addressLine1] setText:@"No address provided"];
    }
}

+ (CGFloat)height
{
    return 62;
}

@end
