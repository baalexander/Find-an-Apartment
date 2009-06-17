#import "PropertyFavoritesViewController.h"

//Dirty when a property added to favorites, but have not refetched
//This prevents unnecessary fetches
//Static because many of the functions that access this are static
static BOOL isDirty = NO;


@implementation PropertyFavoritesViewController


#pragma mark -
#pragma mark PropertyFavoritesViewController

//Performas a deep copy on the property then adds to favorites.
//Returns NO if property is already in favorites.
+ (BOOL)addProperty:(PropertySummary *)summary
{
    //Do NOT add if already a favorite
    if ([PropertyFavoritesViewController isPropertyAFavorite:summary])
    {
        return NO;
    }
    
    NSManagedObjectContext *managedObjectContext = [summary managedObjectContext];

    PropertyHistory *history = [PropertyFavoritesViewController favoriteHistoryFromContext:managedObjectContext];
    if (history == nil)
    {
        NSLog(@"Error getting a favorites History.");
        
        return NO;
    }
    
    //Deep copies the Summary
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
    PropertySummary *copySummary = [[PropertySummary alloc] initWithEntity:summaryEntity insertIntoManagedObjectContext:managedObjectContext];
    NSDictionary *summaryAttributes = [summaryEntity attributesByName];
    for (NSString *key in summaryAttributes)
    {
        [copySummary setValue:[summary valueForKey:key] forKey:key];
    }
    
    //Deep copies the Details
    PropertyDetails *details = [summary details];
    NSEntityDescription *detailsEntity = [NSEntityDescription entityForName:@"PropertyDetails" inManagedObjectContext:managedObjectContext];
    PropertyDetails *copyDetails = [[PropertyDetails alloc] initWithEntity:detailsEntity insertIntoManagedObjectContext:managedObjectContext];
    NSDictionary *detailsAttributes = [detailsEntity attributesByName];
    for (NSString *key in detailsAttributes)
    {
        [copyDetails setValue:[details valueForKey:key] forKey:key];
    }
    
    //Copies relationships
    [copySummary setDetails:copyDetails];
    
    //Adds summary to favorites History
    [history addSummariesObject:copySummary];
    
    //Saves!
    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        NSLog(@"Error saving favorites History.");
    }
    
    isDirty = YES;

    return YES;
}

//Returns YES if already a favorite
+ (BOOL)isPropertyAFavorite:(PropertySummary *)summary
{
    NSManagedObjectContext *managedObjectContext = [summary managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:summaryEntity];
    
    NSArray *predicates = [[NSArray alloc] initWithObjects:
                           [NSPredicate predicateWithFormat:@"(link == %@)", [summary link]], 
                           [NSPredicate predicateWithFormat:@"(history.isFavorite == YES)"], 
                           nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [predicates release];
    [fetchRequest setPredicate:compoundPredicate];
    
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchResults == nil)
    {
		// Handle the error.
        NSLog(@"Error checking if property is a favorite.");
	}

    return [fetchResults count] > 0;
}

+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:historyEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isFavorite == YES)"];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:1];
    
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchResults == nil)
    {
		// Handle the error.
        NSLog(@"Error fetching favorites History object.");
        
        return nil;
	}
    
    //No favorites History, creates a new one
    if ([fetchResults count] == 0)
    {
        NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
        PropertyHistory *history = [[PropertyHistory alloc] initWithEntity:historyEntity insertIntoManagedObjectContext:managedObjectContext];
        
        //Sets History attributes
        [history setTitle:@"Favorites"];
        
        NSDate *now = [[NSDate alloc] init];
        [history setCreated:now];
        [now release];

        NSNumber *yesObject = [[NSNumber alloc] initWithBool:YES];
        [history setIsFavorite:yesObject];
        [yesObject release];
        
        return history;
    }
    //Gets existing favorites History
    else
    {
        return [fetchResults objectAtIndex:0];
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Is dirty when a favorite was added but have not updated the fetched results controller
    if (isDirty)
    {
        if (![[self fetchedResultsController] performFetch:nil])
        {
            NSLog(@"Error performing fetch in favorite's view will appear.");
            // TODO: Handle the error.
        }
        
        [[self tableView] reloadData];
        
        isDirty = NO;
    }
}

@end
