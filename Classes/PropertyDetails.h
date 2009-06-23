#import <CoreData/CoreData.h>

@class PropertySummary;
@class PropertyImage;

@interface PropertyDetails :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * agent;
@property (nonatomic, retain) NSNumber * bedrooms;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * broker;
@property (nonatomic, retain) NSString * copyrightLink;
@property (nonatomic, retain) NSNumber * squareFeet;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSNumber * bathrooms;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * school;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) PropertySummary * summary;
@property (nonatomic, retain) NSSet* images;

@end


@interface PropertyDetails (CoreDataGeneratedAccessors)
- (void)addImagesObject:(PropertyImage *)value;
- (void)removeImagesObject:(PropertyImage *)value;
- (void)addImages:(NSSet *)value;
- (void)removeImages:(NSSet *)value;

@end

