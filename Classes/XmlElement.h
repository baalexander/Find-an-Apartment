#import <Foundation/Foundation.h>


@interface XmlElement : NSObject
{
    @private
        NSString *name_;
        NSString *value_;
        NSDictionary *attributes_;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSDictionary *attributes;

@end
