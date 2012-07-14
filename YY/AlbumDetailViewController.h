//
//  YYDetailViewController.h
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class Album;

@interface AlbumDetailViewController : UIViewController

@property (strong, nonatomic) id album;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
