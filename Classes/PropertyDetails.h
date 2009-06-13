#import <CoreData/CoreData.h>

@class PropertySummary;

@interface PropertyDetails :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * agent;
@property (nonatomic, retain) NSString * bedrooms;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * broker;
@property (nonatomic, retain) NSString * copyrightLink;
@property (nonatomic, retain) NSString * squareFeet;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * lotSize;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSString * bathrooms;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * school;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) PropertySummary * summary;

@end



