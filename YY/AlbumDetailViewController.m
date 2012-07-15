//
//  YYDetailViewController.m
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "AlbumDetailViewController.h"
#import "AlbumWebResouceViewController.h"
#import "Album.h"
#import "Artist.h"

@interface AlbumDetailViewController ()
- (void)configureView;
@end

@implementation AlbumDetailViewController

@synthesize album = _album;
@synthesize summary = _summary;
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
        //setup the navigation item
        self.navigationItem.title = self.album.title;
        
        //setup the summary
        NSString * albumDetail = [NSString stringWithFormat:@"title %@:singer %@",
                                  self.album.title ,
                                  self.album.artist.name];
        self.summary.text = albumDetail;                              
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
    [self setSummary:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
   // self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"tryListen"]){
        AlbumWebResouceViewController * destViewController = (AlbumWebResouceViewController*)[segue destinationViewController];
        //TODO
        destViewController.urlString = @"http://www.apple.com";
    }
}

@end
