//
//  AlbumWebResouceViewController.h
//  YY
//
//  Created by Pierr Chen on 12-7-15.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumWebResouceViewController : UIViewController <UIWebViewDelegate> 
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)navigateBack;

- (IBAction)navigateForward;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *browserForwardButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *browserBackButton;
@property (nonatomic,copy) NSString *urlString;
@end
