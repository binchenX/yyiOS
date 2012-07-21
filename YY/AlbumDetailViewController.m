//
//  YYDetailViewController.m
//  YY
//
//  Created by Pierr Chen on 12-7-14.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

//#import <AVAudioPlayer.h>

#import "AlbumDetailViewController.h"
#import "AlbumWebResouceViewController.h"
#import "Album.h"
#import "Artist.h"

#import <SDWebImage/UIImageView+WebCache.h>

//#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
//#import <AudioToolbox/AudioToolbox.h>

@interface AlbumDetailViewController ()
{
    UIImage *placeHolderImage;
}
- (void)configureView;

@end

@implementation AlbumDetailViewController

@synthesize album = _album;
@synthesize coverBig = _coverBig;
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

- (UIImage *)placeHolderImage
{
    if(placeHolderImage == nil){
        NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"album1" ofType:@"jpg"];
        placeHolderImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    return placeHolderImage;
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
        
        if(self.album.detail!=nil){
            albumDetail = [albumDetail stringByAppendingString:self.album.detail];
        }
        
        self.summary.text = albumDetail;   
        [self.coverBig setImageWithURL:[NSURL URLWithString:self.album.coverBigUrl]
                      placeholderImage:[self placeHolderImage]];
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
    [self setSummary:nil];
    [self setCoverBig:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
   // self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}




//These won't work due to a bug in the iOs simulator
//http://stackoverflow.com/questions/7961840/what-does-this-gdb-output-mean
//another options is to use Safari to play the audio file

- (void)playAudio
{
    NSString* resourcePath = @"http://localhost:3000/test.mp3"; //your url
    NSData *_objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourcePath]];
    NSError *error;
    AVAudioPlayer * audioPlayer = [[AVAudioPlayer alloc] initWithData:_objectData error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.volume = 1.0f;
    [audioPlayer prepareToPlay];
    
    if (audioPlayer == nil){
        NSLog(@"%@", [error description]);
    }else{
        [audioPlayer play];
    }
}


#pragma mark - segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"tryListen"]){
        AlbumWebResouceViewController * destViewController = (AlbumWebResouceViewController*)[segue destinationViewController];
        destViewController.urlString = self.album.listenUrl;
        //destViewController.urlString = @"http://localhost:3000/test.mp3";
        destViewController.navigationItem.title = [destViewController.navigationItem.title stringByAppendingString:self.album.title];
    }
}

- (IBAction)downLoad:(id)sender {
    
    [self playAudio];
}
@end
