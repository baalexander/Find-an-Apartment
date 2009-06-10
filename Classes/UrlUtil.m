#import "UrlUtil.h"


@implementation UrlUtil


#pragma mark -
#pragma mark UrlUtil

//Encodes URL so can be embedded within another URL.
+ (NSString *)encodeEmbeddedUrl:(NSString *)url
{
	NSMutableString *mutableURL = [NSMutableString stringWithString:[UrlUtil encodeUrl:url]];
	[mutableURL replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableURL length])];
	
	return mutableURL;
}

+ (NSString *)encodeUrl:(NSString *)url
{
	NSMutableString *mutableUrl = [NSMutableString stringWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[mutableUrl replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableUrl length])];
	[mutableUrl replaceOccurrencesOfString:@"'" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableUrl length])];
	
	return mutableUrl;
}


@end
