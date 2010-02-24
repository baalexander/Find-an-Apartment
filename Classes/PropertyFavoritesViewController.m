#import "PropertyFavoritesViewController.h"

#import "PropertyResultsConstants.h"
#import "PropertyListEmailerViewController.h"
#import "PropertyDetails.h"
#import "PropertyImage.h"


@implementation PropertyFavoritesViewController


#pragma mark -
#pragma mark PropertyFavoritesViewController

- (void)dealloc
{
    [super dealloc];
}

// Performas a deep copy on the property then adds to favorites.
// Is not called copyProperty because the copy prefix implies returning a copied
// object.
// Returns NO if property is already in favorites.
+ (BOOL)addCopyOfProperty:(PropertySummary *)property
{
    // Do not add if already a favorite
    if ([PropertyFavoritesViewController isPropertyAFavorite:property])
    {
        return NO;
    }
    
    NSManagedObjectContext *managedObjectContext = [property managedObjectContext];

    PropertyHistory *history = [PropertyFavoritesViewController favoriteHistoryFromContext:managedObjectContext];
    if (history == nil)
    {
        DebugLog(@"Error getting a favorite History.");
        
        return NO;
    }
    
    // Deep copies the Property Summary
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary"
                                                     inManagedObjectContext:managedObjectContext];
    PropertySummary *copySummary = [[PropertySummary alloc] initWithEntity:summaryEntity
                                            insertIntoManagedObjectContext:managedObjectContext];
    NSDictionary *summaryAttributes = [summaryEntity attributesByName];
    for (NSString *key in summaryAttributes)
    {
        [copySummary setValue:[property valueForKey:key] forKey:key];
    }
    
    // Deep copies the Property Details
    PropertyDetails *details = [property details];
    NSEntityDescription *detailsEntity = [NSEntityDescription entityForName:@"PropertyDetails"
                                                     inManagedObjectContext:managedObjectContext];
    PropertyDetails *copyDetails = [[PropertyDetails alloc] initWithEntity:detailsEntity
                                            insertIntoManagedObjectContext:managedObjectContext];
    NSDictionary *detailsAttributes = [detailsEntity attributesByName];
    for (NSString *key in detailsAttributes)
    {
        [copyDetails setValue:[details valueForKey:key] forKey:key];
    }
    
    // Deep copies the Property Images
    NSSet *images = [details images];
    for (PropertyImage *image in images)
    {
        NSEntityDescription *imageEntity = [NSEntityDescription entityForName:@"PropertyImage"
                                                       inManagedObjectContext:managedObjectContext];
        PropertyImage *copyImage = [[PropertyImage alloc] initWithEntity:imageEntity
                                          insertIntoManagedObjectContext:managedObjectContext];
        NSDictionary *imageAttributes = [imageEntity attributesByName];
        for (NSString *key in imageAttributes)
        {
            [copyImage setValue:[image valueForKey:key] forKey:key];
        }
        
        // Adds to Copy Details
        [copyDetails addImagesObject:copyImage];
        [copyImage release];
    }
    
    // Adds details to summary
    [copySummary setDetails:copyDetails];
    [copyDetails release];
    
    // Adds summary to favorites History
    [history addSummariesObject:copySummary];
    [copySummary release];
    
    // Saves
    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        DebugLog(@"Error saving favorites History.");
    }

    return YES;
}

// Returns YES if already a favorite
+ (BOOL)isPropertyAFavorite:(PropertySummary *)summary
{
    NSManagedObjectContext *managedObjectContext = [summary managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *summaryEntity = [NSEntityDescription entityForName:@"PropertySummary"
                                                     inManagedObjectContext:managedObjectContext];
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
    [fetchRequest release];
    if (fetchResults == nil)
    {
        DebugLog(@"Error checking if property is a favorite.");
    }

    return [fetchResults count] > 0;
}

+ (PropertyHistory *)favoriteHistoryFromContext:(NSManagedObjectContext *)managedObjectContext
{
    PropertyHistory *history = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:historyEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isFavorite == YES)"];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    // Error fetching
    if (fetchResults == nil)
    {
        DebugLog(@"Error fetching favorites History object.");
        
        history = nil;
    }
    // No favorites History, creates a new one
    else if ([fetchResults count] == 0)
    {
        NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"PropertyHistory"
                                                         inManagedObjectContext:managedObjectContext];
        history = [[[PropertyHistory alloc] initWithEntity:historyEntity
                            insertIntoManagedObjectContext:managedObjectContext]
                   autorelease];
        
        // Sets History attributes
        [history setTitle:@"Favorites"];
        
        NSDate *now = [[NSDate alloc] init];
        [history setCreated:now];
        [now release];

        NSNumber *yesObject = [[NSNumber alloc] initWithBool:YES];
        [history setIsFavorite:yesObject];
        [yesObject release];
    }
    // Gets existing favorites History
    else
    {
        history = [fetchResults objectAtIndex:0];
    }
    
    return history;
}

- (IBAction)changeView:(id)sender
{
    [super changeView:sender];
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    // Enables Edit button if going to List view
    if ([segmentedControl selectedSegmentIndex] == kListItem)
    {
        [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    }
    // Disables Edit button if not switching to a List view
    else
    {
        [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
    }

}

- (void)share:(id)sender
{    
    PropertyListEmailerViewController *listEmailer = [[PropertyListEmailerViewController alloc] init];
    [listEmailer setMailComposeDelegate:self];
    
    NSArray *properties = [[self fetchedResultsController] fetchedObjects];
    [listEmailer setProperties:properties];
    
    [self presentModalViewController:listEmailer animated:YES];
    [listEmailer release];
}

- (void)edit:(id)sender
{
    UITableView *tableView = [[self listViewController] tableView];
    
    // Switches editing status
    BOOL isEditing = ![tableView isEditing];
    
    [tableView setEditing:isEditing animated:YES];
    
    // Switches Edit button to Done or Edit depending on status
    UIBarButtonItem *editButton;
    if ([tableView isEditing])
    {
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(edit:)];
    }
    else
    {
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                   target:self
                                                                   action:@selector(edit:)];
    }
    [[self navigationItem] setLeftBarButtonItem:editButton];
    [editButton release];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSFetchedResultsController *fetchedResultsController = [super fetchedResultsController];
    [fetchedResultsController setDelegate:self];
    
    return fetchedResultsController;
}


#pragma mark -
#pragma mark PropertyResultsDataSource

- (void)view:(UIView *)view deletePropertyAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    // Deletes the property, should cascade to delete Details
    PropertySummary *property = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSManagedObjectContext *managedObjectContext = [property managedObjectContext];
    [managedObjectContext deleteObject:property];
    
    // Commit the change.
    NSError *error;
    if (![managedObjectContext save:&error])
    {
        DebugLog(@"Error saving after deleting a property.");
    }
    
    // Fetched results controller delegate handles removing property from the
    // view controllers
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove title because not enough room
    [self setTitle:@""];
    
    // Add the Edit button to the left in the navigation bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(edit:)];
    [[self navigationItem] setLeftBarButtonItem:editButton];
    [editButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Could be switching tabs to the Favorites view controller. If the
    // Favorites view controller is already on the Map view and the Map view is
    // out of sync (dirty), then need to repopulate the Map view
    if ([self mapIsDirty])
    {
        [self setMapIsDirty:NO];
        
        // Repopulate the map
        [self geocodeNextProperty];
    }
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, now
    // prepare the table view for updates.
    [[[self listViewController] tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    // Only concerned with inserts and deletes
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete)
    {
        // The map will be out of sync after the change action
        // Reset the map and stop any geocoding
        // When to repopulate the map depends on the action
        [[self mapViewController] resetMap];
        [self resetGeocoding];
        
        // Signal for the map to be repopulated later (when the view appears)
        // Do not repopulate the map right now
        // Repopulating the map means re-geocoding all the properties. But
        // geocoding saves the context after each property's coordinates are
        // set. Since this delegate is called before the original insert or
        // delete action context saves, an error will result.
        [self setMapIsDirty:YES];

        // Updates the List view with the changes
        UITableView *tableView = [[self listViewController] tableView];
        if (type == NSFetchedResultsChangeInsert)
        {
            // Inserts row into the List view controller
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:newIndexPath, nil];
            [tableView insertRowsAtIndexPaths:indexPaths
                             withRowAnimation:UITableViewRowAnimationFade];
            [indexPaths release];
        }
        else if (type == NSFetchedResultsChangeDelete)
        {
            // Deletes row from the List view controller
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:UITableViewRowAnimationFade];
            [indexPaths release];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, now tell
    // the table view to process all updates.
    [[[self listViewController] tableView] endUpdates];
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

@end
