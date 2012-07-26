//
//  YYMasterViewController.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
//for AlbumListDataDelegate
#import "AlbumDetailViewController.h"
#import <CoreData/CoreData.h>

@interface AlbumsListViewController : UITableViewController <NSFetchedResultsControllerDelegate, NSURLConnectionDataDelegate,MBProgressHUDDelegate , AlbumListDataDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *backgroundMOC;
@end
