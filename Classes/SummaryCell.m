#import "SummaryCell.h"


@implementation SummaryCell

@synthesize title = title_;
@synthesize subtitle = subtitle_;
@synthesize summary = summary_;
@synthesize price = price_;


#pragma mark -
#pragma mark SummaryCell

- (void)dealloc
{
    [title_ release];
    [subtitle_ release];
    [summary_ release];
    [price_ release];
    
    [super dealloc];
}

#pragma mark UIView

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    //Hide the price label when editing to make room for the delete button
    [[self price] setHidden:[self isEditing]];
}


@end
