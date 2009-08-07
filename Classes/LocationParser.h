#import <Foundation/Foundation.h>


@interface LocationParser : NSObject
{
    @private
        NSString *location_;
        NSMutableArray *locationArray_;
}

@property (nonatomic, copy) NSString *location;

- (id)initWithLocation:(NSString *)location;
- (NSString *)street;
- (NSString *)cityStateZip;
- (NSString *)postalCode;

@end
