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
#import "AudioStreamer.h"

#import <SDWebImage/UIImageView+WebCache.h>

//#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
//#import <AudioToolbox/AudioToolbox.h>



CGFloat kMovieViewOffsetX = 20.0;
CGFloat kMovieViewOffsetY = 20.0;

@interface AlbumDetailViewController ()
{
    UIImage *placeHolderImage;
    AudioStreamer *streamer;
}
- (void)configureView;

@property (retain) MPMoviePlayerController *moviePlayerController;

@end

@implementation AlbumDetailViewController
@synthesize playerViewHolder = _playerViewHolder;

@synthesize album = _album;
@synthesize coverBig = _coverBig;
@synthesize recommendStar = _recommendStar;
@synthesize summary = _summary;
@synthesize delegate = _delegate;
@synthesize moviePlayerController = _moviePlayerController;

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
        NSString * albumDetail = [NSString stringWithFormat:@"%@",self.album.artist.name];
        albumDetail = [albumDetail stringByAppendingFormat:@" - %@",self.album.title];
        
        //disble detail
//        if(self.album.detail!=nil){
//            albumDetail = [albumDetail stringByAppendingString:self.album.detail];
//        }
        
        self.summary.text = albumDetail; 
        NSString *coverImage = self.album.coverBigUrl;
        if(coverImage == nil){
            coverImage = self.album.coverThumbnailUrl;
        }
        
        //show the recommendation start if the rating is 5
        if([self.album.rating intValue]  == 5 ){
            [self.recommendStar setHidden:NO];
        }
        
        [self.coverBig setImageWithURL:[NSURL URLWithString:coverImage]
                      placeholderImage:[self placeHolderImage]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    //self.tabBarController.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidUnload
{
    [self setSummary:nil];
    [self setSummary:nil];
    [self setCoverBig:nil];
    [self setRecommendStar:nil];
    [self setPlayerViewHolder:nil];
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

- (void)playAudio:(NSString*)url
{
    //NSString* resourcePath = @"http://localhost:3000/test.mp3"; //your url
    NSData *_objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
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
    }else if([@"showWebLink" isEqualToString:[segue identifier]]){
        AlbumWebResouceViewController * destViewController = (AlbumWebResouceViewController*)[segue destinationViewController];
        destViewController.urlString = self.album.detailUrl;
        destViewController.navigationItem.title = @"外部信息";
    }
}

- (IBAction)downLoad:(id)sender {
    
    //[self playAudio];
}

#pragma mark - gesture handler
- (IBAction)handleSwipe:(UISwipeGestureRecognizer*)recognizer {
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft ){
        NSLog(@"swiped left");
        [self showNext];
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        NSLog(@"swiped right");
        [self showPrevious];

    }
    
}


- (void)showNext
{
    if ([self.delegate respondsToSelector:@selector(getNext)]) 
    {
        Album *album = [self.delegate getNext];
        self.album = album;
    }
    
}


- (void)showPrevious
{
    if ([self.delegate respondsToSelector:@selector(getPrevious)]) {
        Album *album = [self.delegate getPrevious];
        self.album = album;
    }
    
}

#pragma mark - Media Player 

- (IBAction)play:(id)sender {
    NSString * url = @"https://s3-ap-southeast-1.amazonaws.com/yyapp/lizhi_youxi.mp3";
    //[self playAudio:url];
    //[self playMovieStream:[NSURL URLWithString:url]];
    [self playAudioStream:[NSURL URLWithString:url]];
}



/* Called soon after the Play Movie button is pressed to play the streaming movie. */
-(void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    /* If we have a streaming url then specify the movie source type. */
    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame) 
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    [self createAndPlayMovieForURL:movieFileURL sourceType:movieSourceType];   
}


/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and 
 controls to the existing view hierarchy.
 */
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType 
{    
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player) 
    {
        /* Save the movie object. */
        [self setMoviePlayerController:player];
        
        /* Register the current object as an observer for the movie
         notifications. */
        [self installMovieNotificationObservers];
        
        /* Specify the URL that points to the movie file. */
        [player setContentURL:movieURL];        
        
        /* If you specify the movie type before playing the movie it can result 
         in faster load times. */
        [player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
        //[self applyUserSettingsToMoviePlayer];
        
        /* Add a background view as a subview to hide our other view controls 
         underneath during movie playback. */
        //[self.view addSubview:self.backgroundView];
        
        //CGRect viewInsetRect = CGRectInset ([self.playerViewHolder  bounds],5,5);
        
        //CGRect rect = CGRectMake(20, 392, 200, 20);
        /* Inset the movie frame in the parent view frame. */
        //[[player view] setFrame:rect];
        
        [player view].backgroundColor = [UIColor lightGrayColor];
        
        /* To present a movie in your application, incorporate the view contained 
         in a movie player’s view property into your application’s view hierarchy. 
         Be sure to size the frame correctly. */
        [self.view addSubview: [player view]];        
    }    
}

/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
    /* Play the movie! */
    [[self moviePlayerController] play];
}



#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadStateDidChange:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mediaIsPreparedToPlayDidChange:) 
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackStateDidChange:) 
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                               object:player];        
}


#pragma mark Movie Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]; 
	switch ([reason integerValue]) 
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"] 
                                waitUntilDone:NO];
           // [self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
           // [self removeMovieViewFromViewHierarchy];
           // [self removeOverlayView];
           // [self.backgroundView removeFromSuperview];
			break;
            
		default:
			break;
	}
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification 
{   
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;	
    
	/* The load state is not known at this time. */
//	if (loadState & MPMovieLoadStateUnknown)
//	{
//        [self.overlayController setLoadStateDisplayString:@"n/a"];
//        
//        [overlayController setLoadStateDisplayString:@"unknown"];       
//	}
	
//	/* The buffer has enough data that playback can begin, but it 
//	 may run out of data before playback finishes. */
//	if (loadState & MPMovieLoadStatePlayable)
//	{
//        [overlayController setLoadStateDisplayString:@"playable"];
//	}
//	
//	/* Enough data has been buffered for playback to continue uninterrupted. */
//	if (loadState & MPMovieLoadStatePlaythroughOK)
//	{
//        // Add an overlay view on top of the movie view
//        [self addOverlayView];
//        
//        [overlayController setLoadStateDisplayString:@"playthrough ok"];
//	}
//	
//	/* The buffering of data has stalled. */
//	if (loadState & MPMovieLoadStateStalled)
//	{
//        [overlayController setLoadStateDisplayString:@"stalled"];
//	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    
//	/* Playback is currently stopped. */
//	if (player.playbackState == MPMoviePlaybackStateStopped) 
//	{
//        [overlayController setPlaybackStateDisplayString:@"stopped"];
//	}
//	/*  Playback is currently under way. */
//	else if (player.playbackState == MPMoviePlaybackStatePlaying) 
//	{
//        [overlayController setPlaybackStateDisplayString:@"playing"];
//	}
//	/* Playback is currently paused. */
//	else if (player.playbackState == MPMoviePlaybackStatePaused) 
//	{
//        [overlayController setPlaybackStateDisplayString:@"paused"];
//	}
//	/* Playback is temporarily interrupted, perhaps because the buffer 
//	 ran out of content. */
//	else if (player.playbackState == MPMoviePlaybackStateInterrupted) 
//	{
//        [overlayController setPlaybackStateDisplayString:@"interrupted"];
//	}
}

/* Notifies observers of a change in the prepared-to-play state of an object 
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
	// Add an overlay view on top of the movie view
    //[self addOverlayView];
}



#pragma mark - player using Audio Streamer
-(void)playAudioStream:(NSURL *)audioUrl
{
        [self createStreamer:audioUrl];
    
    	[streamer start];
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];

		[streamer stop];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(NSURL*)url
{
//	if (streamer)
//	{
//		return;
//	}
    
	[self destroyStreamer];
    
	streamer = [[AudioStreamer alloc] initWithURL:url];
	

	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}


- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		//[self setButtonImageNamed:@"loadingbutton.png"];
	}
	else if ([streamer isPlaying])
	{
		//[self setButtonImageNamed:@"stopbutton.png"];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		//[self setButtonImageNamed:@"playbutton.png"];
	}
}


@end
