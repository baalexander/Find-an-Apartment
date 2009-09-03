#import "PropertyFavoritesViewController.h"

#import "PropertyMapViewController.h"
#import "PropertyListEmailerViewController.h"
#import "PropertyImage.h"
#import "PropertyListAndMapConstants.h"


@implementation PropertyFavoritesViewController


#pragma mark -
#pragma mark PropertyFavoritesViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {

    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

//Performas a deep copy on the property then adds to favorites. Is not called copyProperty because the copy prefix implies returning a copied object.
//Returns NO if property is already in favorites.
+ (BOOL)addCopyOfProperty:(PropertySummary *)summary
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
        DebugLog(@"Error getting a favorites History.");
        
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
    
    //Deep copies the Images
    NSSet *images = [details images];
    for (PropertyImage *image in images)
    {
        NSEntityDescription *imageEntity = [NSEntityDescription entityForName:@"PropertyImage" inManagedObjectContext:managedObjectContext];
        PropertyImage *copyImage = [[PropertyImage alloc] initWithEntity:imageEntity insertIntoManagedObjectContext:managedObjectContext];
        NSDictionary *imageAttributes = [imageEntity attributesByName];
        for (NSString *key in imageAttributes)
        {
            [copyImage setValue:[image valueForKey:key] forKey:key];
        }
        
        //Adds to Copy Details
        [copyDetails addImagesObject:copyImage];
        [copyImage release];
    }
    
    //Adds details to summary
    [copySummary setDetails:copyDetails];
    [copyDetails release];
    
    //Adds summary to favorites History
    [history addSummariesObject:copySummary];
    [copySummary release];
    
    //Saves!
    NSError *error = nil;
    if (![managedObjectContext save:&error])
    {
        DebugLog(@"Error saving favorites History.");
    }

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
    [fetchRequest release];
    if (fetchResults == nil)
    {
        // Handle the error.
        DebugLog(@"Error checking if property is a favorite.");
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
    [fetchRequest release];
    if (fetchResults == nil)
    {
        // Handle the error.
        DebugLog(@"Error fetching favorites History object.");
        
        return nil;
    }
    
    //No favorites History, creates a new one
    if ([fetchResults count] == 0)
    {
        NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"PropertyHistory" inManagedObjectContext:managedObjectContext];
        PropertyHistory *history = [[[PropertyHistory alloc] initWithEntity:historyEntity insertIntoManagedObjectContext:managedObjectContext] autorelease];
        
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

//The segmented control was clicked, handle it here
- (IBAction)changeView:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    //Bring up map
    if ([segmentedControl selectedSegmentIndex] == kMapItem)
    {
        PropertyMapViewController *mapViewController = [[PropertyMapViewController alloc] initWithNibName:@"PropertyMapView" bundle:nil];
        [mapViewController setHistory:[self history]];
        [mapViewController setIsFromFavorites:YES];
        [mapViewController setShouldAddButtonToAnnotation:YES];
        [mapViewController setTitle:@"Favorites"];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[[self navigationController] viewControllers]];
        [viewControllers replaceObjectAtIndex:[viewControllers count] - 1 withObject:mapViewController];
        [mapViewController release];
        [[self navigationController] setViewControllers:viewControllers animated:NO];
        [viewControllers release];
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
    //Switches editing status
    BOOL isEditing = ![[self tableView] isEditing];
    [[self tableView] setEditing:isEditing animated:YES];
    
    if ([[self tableView] isEditing])
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
        [[self navigationItem] setLeftBarButtonItem:doneButton];
        [doneButton release];        
    }
    else
    {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        [[self navigationItem] setLeftBarButtonItem:editButton];
        [editButton release];        
    }    
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSFetchedResultsController *fetchedResultsController = [super fetchedResultsController];
    [fetchedResultsController setDelegate:self];
    
    return fetchedResultsController;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Deletes the summary, should cascade to delete Details
        PropertySummary *summary = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSManagedObjectContext *managedObjectContext = [summary managedObjectContext];
        [managedObjectContext deleteObject:summary];
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error])
        {
            DebugLog(@"Error saving the deletion in Favorites.");
        }
        
        //The fetched results controller delegate calls will handle changes to the table
    }
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add the Edit button to the left in the navigation bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    [[self navigationItem] setLeftBarButtonItem:editButton];
    [editButton release];
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:newIndexPath, nil];
        [[self tableView] insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [indexPaths release];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [indexPaths release];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert)
    {
        [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [[self tableView] endUpdates];
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

@end
