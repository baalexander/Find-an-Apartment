#import "LocationParser.h"


@interface LocationParser ()
@property (nonatomic, retain) NSMutableArray *locationArray;
- (void)parse;
@end

@implementation LocationParser

@synthesize location = location_;
@synthesize locationArray = locationArray_;


#pragma mark -
#pragma mark LocationParser

- (id)initWithLocation:(NSString *)location
{
    if ((self = [super init]))
    {
        [self setLocation:location];
    }
    
    return self;
}

- (void)dealloc
{
    [location_ release];
    [locationArray_ release];

    [super dealloc];
}

+ (NSString *)locationWithStreet:(NSString *)street withCity:(NSString *)city withState:(NSString *)state withPostalCode:(NSString *)postalCode
{
    NSMutableString *location = [[[NSMutableString alloc] init] autorelease];
    
    if (street != nil)
    {
        [location appendFormat:@"%@, ", street];
    }
    if (city != nil)
    {
        [location appendFormat:@"%@, ", city];
    }
    if (state != nil)
    {
        [location appendFormat:@"%@, ", state];
    }
    if (postalCode != nil)
    {
        [location appendFormat:@"%@, ", postalCode];
    }
    
    return location;
}

- (void)setLocation:(NSString *)location
{
    [location_ release];
    location_ = [location copy];
    
    //Parse the new location
    [self parse];
}

- (NSString *)street
{
    if ([[self locationArray] count] > 1)
    {
        return [[self locationArray] objectAtIndex:0];
    }
    else
    {
        return @"";
    }
    
}

- (NSString *)cityStateZip
{
    if ([[self locationArray] count] > 1)
    {
        return [[self locationArray] objectAtIndex:1];
    }
    else if ([[self locationArray] count] > 0)
    {
        return [[self locationArray] objectAtIndex:0];
    }
    else
    {
        return @"";
    }
}

- (NSString *)postalCode
{
    NSString *cityStateZip = [self cityStateZip];
    
    //Looks for last set of numbers
    NSRange range = [cityStateZip rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
	if (range.location != NSNotFound && range.location >= 4)
	{
		NSString *possibleZipCode = [cityStateZip substringWithRange:NSMakeRange(range.location-4, 5)];
		NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
		if ([possibleZipCode rangeOfCharacterFromSet:nonDigits].location == NSNotFound)
		{
			return possibleZipCode;
		}
	}
	
	return @"";
}

- (void)parse
{
	//Holds address as two parts: street and city,state,zip
	NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    [self setLocationArray:locationArray];
    [locationArray release];
    
	NSArray *locationComponents = [[self location] componentsSeparatedByString:@","];
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
						[[self locationArray] addObject:locationComponent];
						continue;
					}
				}
			}
			
			//Ignores USA
			if ([locationComponent rangeOfString:@"USA" options:NSCaseInsensitiveSearch].location != NSNotFound)
			{
				continue;
			}
			
			[mutableLocation appendString:[locationComponent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			[mutableLocation appendString:@", "];
		}
		
		NSString *cityStateZip = [mutableLocation substringToIndex:[mutableLocation length]-2];
		[mutableLocation release];
		[[self locationArray] addObject:cityStateZip];
	}
	//Only one part in location, sets as-is
	else
	{
		[[self locationArray] addObject:[self location]];
	}
}

@end
