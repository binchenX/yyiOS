//
//  YYDetailViewController.m
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "AlbumDetailViewController.h"

@interface AlbumDetailViewController ()
- (void)configureView;
@end

@implementation AlbumDetailViewController

@synthesize album = _album;
//@synthesize detailDescriptionLabel = _detailDescriptionLabel;

#pragma mark - Managing the detail item

- (void)setAlbum:(id)newAlbum
{
    if (_album != newAlbum) {
        _album = newAlbum;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.album) {
        NSString * albumDetail = [NSString stringWithFormat:@"title %@:singer %@",
                                  [self.album valueForKey:@"title" ],
                                  [[self.album valueForKey:@"artist"] valueForKey:@"name"]
                                  ];
        
        //self.detailDescriptionLabel.text = albumDetail;
       // self.detailDescriptionLabel.text = [[self.album valueForKey:@"title"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
   // self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
