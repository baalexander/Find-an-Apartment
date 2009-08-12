#import <Foundation/Foundation.h>


@interface LocationParser : NSObject
{
    @private
        NSString *location_;
        NSMutableArray *locationArray_;
}

@property (nonatomic, copy) NSString *location;

+ (NSString *)locationWithStreet:(NSString *)street withCity:(NSString *)city withState:(NSString *)state withPostalCode:(NSString *)postalCode;
- (id)initWithLocation:(NSString *)location;
- (NSString *)street;
- (NSString *)cityStateZip;
- (NSString *)postalCode;

@end
