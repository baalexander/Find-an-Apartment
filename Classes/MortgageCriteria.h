#import <CoreData/CoreData.h>


@interface MortgageCriteria :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * cashDown;
@property (nonatomic, retain) NSNumber * loanTerm;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSNumber * percentDown;
@property (nonatomic, retain) NSNumber * loanRate;
@property (nonatomic, retain) NSNumber * loanAmount;
@property (nonatomic, retain) NSNumber * purchasePrice;

@end



