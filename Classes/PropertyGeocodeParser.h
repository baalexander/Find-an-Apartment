#import "XmlParser.h"

#import "PropertySummary.h"


@interface PropertyGeocodeParser : XmlParser
{
    @private
        PropertySummary *summary_;
}

@property (nonatomic, retain) PropertySummary *summary;

- (id)initWithSummary:(PropertySummary *)summary;

@end
