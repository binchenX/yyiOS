//
//  YYDetailViewController.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;

@interface AlbumDetailViewController : UIViewController

@property (strong, nonatomic) Album * album;

@property (strong, nonatomic) IBOutlet UILabel *summary;

//@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
