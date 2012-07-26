//
//  YYMasterViewController.m
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "AlbumsListViewController.h"
#import "AlbumDetailViewController.h"

#import "Album.h"
#import "Artist.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "MBProgressHUD.h"



@interface AlbumsListViewController ()
{
    NSMutableData *jsonData;
    NSURLConnection *connection;
    NSDateFormatter * rfc3339DateFormatter;
    NSDateFormatter * userVisiableDateFormatter;
    UIImage * placeHolderImage;
    NSIndexPath *currentViewedIndexPath;
    
    MBProgressHUD *HUD;
    
    long long expectedLength;
	long long currentLength;
    
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AlbumsListViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize backgroundMOC = _backgroundMOC;


#pragma mark - view life cycle management
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
        target:self action:@selector(updateAlbums:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - update action
- (void)updateAlbums:(id)sender
{
    
    [self fetchUpdateFromServer];
}

- (void)insertAlbum:(NSDictionary*)album
{
    
    NSString *title = [album objectForKey:@"title"];
    NSString *detail = [album objectForKey:@"content"];
    NSString *releaseDate = [album objectForKey:@"happen_at"];
    NSString *coverThumbnailUrl = [album objectForKey:@"image_small"];
    NSString *coverBigUrl = [album objectForKey:@"image_big"];
    NSString *detailUrl = [album objectForKey:@"link_mobile"];
    
    NSManagedObjectContext *context = self.backgroundMOC;
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Album *newAlbum = (Album*) [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    newAlbum.title = title;    
    newAlbum.detail = detail;
    newAlbum.releaseDate = [self.rfc3339DateFormatter dateFromString:releaseDate];
    newAlbum.coverThumbnailUrl = coverThumbnailUrl;
    newAlbum.coverBigUrl = coverBigUrl;
    newAlbum.detailUrl = detailUrl;
    
   
    
    NSString *singer = [album objectForKey:@"singer"];
    
    //hack
    if ([singer isEqualToString:@"窦唯"]) {
        newAlbum.rating = [NSNumber numberWithInt:5];
    }
    
    Artist *artist = (Artist *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"Artist"
                                inManagedObjectContext:self.backgroundMOC]; 
   
//TODO:find if singer exist ,if not create it
    artist.gerne = @"rock";
    artist.name  = singer;
    
    //an album MUST have a artist
    newAlbum.artist = artist;

    // Save the context.
    //[self saveContext];
   


}

- (void) saveContext
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (BOOL) albumDoesNotExsitByTitle:(NSString*)albumTitle
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:self.managedObjectContext];
    
    //can not use block predict with fetch request
    //check http://stackoverflow.com/questions/3543208/nsfetchrequest-and-predicatewithblock
//    NSPredicate *predict = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings){
//        Album * album = (Album*)evaluatedObject;
//        return [album.title isEqualToString:albumTitle];
//    }];
    
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"title ==  %@",albumTitle];
    
    [request setEntity:entity];
    [request setPredicate:predict];
    
    NSError *error = nil;
    
    NSUInteger count = [self.backgroundMOC countForFetchRequest:request error:&error];
    
    if(error || (count == 0)){
        return YES;
    }
    return NO;
}

- (void)fetchUpdateFromServer
{
    
    jsonData = [[NSMutableData alloc] init];
    
    //NSString *requestUrlSimulator = @"http://localhost:3000/api?tag=album&since=2000-01";
    
    NSString *requestUrlDevice = @"http://www.rock-n-folk.com/api?tag=album&since=2010-01";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrlDevice]];
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.delegate = self;
    HUD.labelText = @"Connecting..";
    NSLog(@"start connecting..");
    
    //[connection start];
    
    // myProgressTask uses the HUD instance to update progress
	//[HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    
    
    
}


- (void)myProgressTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
}


#pragma mark URLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedLength = [response expectedContentLength];
    currentLength = 0;
    //HUD.mode = MBProgressHUDModeDeterminate;
    //HUD.labelText = @"Connecting..";
    NSLog(@"get response");
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [jsonData appendData:data];
    //currentLength += [data length];
	//HUD.progress = currentLength / (float)expectedLength;
    
}

- (NSDateFormatter*) rfc3339DateFormatter
{    
    if (rfc3339DateFormatter == nil) {
        NSLocale *                  enUSPOSIXLocale;
        
        rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    return rfc3339DateFormatter;
}


/**
 * This method will be run in a background thread started by MBProgressHD
 */
 

- (void)updateLocalDatabase
{
    
    self.backgroundMOC = [[NSManagedObjectContext alloc] init];
    
    [self.backgroundMOC setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundMOCDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.backgroundMOC];         


    
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Update..";
    
    NSError *error = nil;
    NSArray *posts = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error){
        abort();
    }
    
    if(![NSJSONSerialization isValidJSONObject:posts]){
        NSLog(@"Not valid JSON object");
        return;
    }
    
    NSUInteger totalUpdate = [posts count];
    
    NSLog(@"get %d posts" , totalUpdate);
   // usleep(2000);
    
    //HUD.mode = MBProgressHUDModeDeterminate;
    //HUD.labelText = @"Update..";
    
    int count = 0 ;
    
    //save those posts
    for (NSDictionary *post in posts){
        NSDictionary *album = (NSDictionary*)[post objectForKey:@"post"];
        NSString *title = [album objectForKey:@"title"];
        
        //we could make sure we only insert but not update in the server 
        //if we need to check while insert we have to saveContext otherwise 
        //NSException(set was mutated while be enumerated) will be thrown
        
        //check:
        //http://stackoverflow.com/questions/3446983/collection-was-mutated-while-being-enumerated-on-executefetchrequest
        
        if([self albumDoesNotExsitByTitle:title]){
            //NSLog(@"add new album %@ ",title);
            [self insertAlbum:album ];
        }else {
            //NSLog(@"album %@ already exsit",title);
        }
        
        count += 1;
        
        //save every 10 items 
        if((count % 10) == 0){
            //save context in batch is much fast than save context for each insert
            [self.backgroundMOC save:NULL];
        }
        HUD.progress = (float)count / totalUpdate; 
    }
    
    NSLog(@"finish update");
  
    //save remaining..
    [self.backgroundMOC save:NULL];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	[HUD hide:YES afterDelay:2];
    
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.backgroundMOC];
    
    [self.backgroundMOC reset]; 
     self.backgroundMOC = nil;

}


- (void)backgroundMOCDidSave:(NSNotification*)notification {    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(backgroundMOCDidSave:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    // We merge the background moc changes in the main moc
    
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish download the data ,will update local db");
    [HUD showWhileExecuting:@selector(updateLocalDatabase) onTarget:self withObject:nil animated:YES];
    
    //[self updateLocalDatabase];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error when updating");
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Update Error";
	[HUD hide:YES afterDelay:2];
    
}


#pragma mark - Table View data source delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
        return [NSString stringWithFormat:NSLocalizedString(@"%@", @"%@"), [sectionInfo name]];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSDateFormatter*)userVisiableDateFormatter
{
    if(userVisiableDateFormatter == nil){
        userVisiableDateFormatter = [[NSDateFormatter alloc] init];
        [userVisiableDateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    return userVisiableDateFormatter;
    
}

/**
 * coverthumbnail place holder image
 */
- (UIImage *)placeHolderImage
{
    if(placeHolderImage == nil){
        NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"album1" ofType:@"jpg"];
        placeHolderImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    return placeHolderImage;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [album.title description];    
    cell.detailTextLabel.text = [self.userVisiableDateFormatter stringFromDate:album.releaseDate];
    
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:album.coverThumbnailUrl]
                placeholderImage:[self placeHolderImage]];
   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

//alternating the backgound color
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}


//TODO:fix table view selectable index

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)table {
//    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
//    return [self.fetchedResultsController sectionIndexTitles];
//    
//}
//
//- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    // tell table which section corresponds to section title/index (e.g. "B",1))
//    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
//}

//do it in the storyboard
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return tableView.bounds.size.height / 4 ;
//}

#pragma mark - segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        currentViewedIndexPath = indexPath;
        Album * album = (Album *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setAlbum:album];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortByAuthorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist.name" ascending:NO];
    
    NSSortDescriptor *sortByReleaseDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"releaseDate" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortByAuthorDescriptor,sortByReleaseDateDescriptor, nil];
    
   [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"artist.name" cacheName:@"AlbumList"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	 HUD = nil;
}


//used to implement swipe in the detail page
#pragma mark - albumDateListDelegate 

- (Album*)getAlbumAtIndex:(NSIndexPath*)indexPath
{
    NSLog(@"AlbumDateListDelegate is called");
    //return (Album*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    return nil;
}


/**
 *get next in current section
 */
 

-(Album*)getNext
{
    
    
    NSInteger nextRow = currentViewedIndexPath.row + 1;
    NSInteger numberOfRowInSection = [self tableView:self.tableView numberOfRowsInSection:currentViewedIndexPath.section];
    
    if(nextRow >= numberOfRowInSection - 1 ){
        nextRow = numberOfRowInSection - 1;
    }
   
    NSIndexPath *next = [NSIndexPath indexPathForRow:nextRow inSection:currentViewedIndexPath.section];  
    
    currentViewedIndexPath = next;
    
    return (Album*)[self.fetchedResultsController objectAtIndexPath:next];
  
    
}

/**
 *get previous in current section
 */

-(Album*)getPrevious
{
    NSInteger nextRow = currentViewedIndexPath.row - 1;
    if(nextRow <0 ){
        nextRow = 0;
    }
    NSIndexPath *next = [NSIndexPath indexPathForRow:nextRow inSection:currentViewedIndexPath.section];  
    
    currentViewedIndexPath = next;
    return (Album*)[self.fetchedResultsController objectAtIndexPath:next];

}



@end
