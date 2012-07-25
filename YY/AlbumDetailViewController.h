//
//  YYDetailViewController.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Album;

@interface AlbumDetailViewController : UIViewController

@property (strong, nonatomic) Album * album;
- (IBAction)downLoad:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *coverBig;
@property (strong, nonatomic) IBOutlet UIImageView *recommendStar;

@property (strong, nonatomic) IBOutlet UITextView *summary;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer*)recognizer;

@property (strong, nonatomic) id delegate;

//@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

- (IBAction)play:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *playerViewHolder;

@end

@protocol AlbumListDataDelegate <NSObject>

-(Album*)getNext;
-(Album*)getPrevious;

@optional
- (Album*)getAlbumAtIndex:(NSIndexPath*)indexPath;
@end