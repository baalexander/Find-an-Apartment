#import <Foundation/Foundation.h>


@interface UrlUtil : NSObject
{
    
}

+ (NSString *)encodeEmbeddedUrl:(NSString *)url;
+ (NSString *)encodeUrl:(NSString *)url;

@end
