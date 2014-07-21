//
//  ViewController.m
//  AudioVideoMerge
//
//  Created by TheAppGuruz-iOS-103 on 26/04/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize videoAsset,audioAsset;
@synthesize activityView;
@synthesize vwMoviePlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [activityView setHidden:YES];
    [vwMoviePlayer setHidden:YES];
}

- (IBAction)btnMergeTapped:(id)sender
{
    [activityView setHidden:NO];
    [activityView startAnimating];
    [vwMoviePlayer setHidden:YES];
    [self performSelector:@selector(mergeAndSave) withObject:nil afterDelay:.6];
}

-(void)mergeAndSave
{
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.
    NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Sound" ofType:@"mp3"]];
    audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we will load video file.
    NSURL *video_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Video" ofType:@"m4v"]];
    videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,audioAsset.duration);
    
    //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //decide the path where you want to store the final video created with audio and video merge.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo.mov"]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    //Now create an AVAssetExportSession object that will save your final video at specified path.
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:_assetExport];
         });
     }
     ];
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                }else{
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                    [alert show];
                                                    [self loadMoviePlayer:outputURL];
                                                }
                                            });
                                    }];
        }
    }
    audioAsset = nil;
    videoAsset = nil;
    [activityView stopAnimating];
    [activityView setHidden:YES];
}

-(void)loadMoviePlayer:(NSURL*)moviePath
{
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:moviePath];
    moviePlayer.view.hidden = NO;
    
    moviePlayer.view.frame = CGRectMake(0, 0, vwMoviePlayer.frame.size.width, vwMoviePlayer.frame.size.height);
    moviePlayer.view.backgroundColor = [UIColor clearColor];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    moviePlayer.fullscreen = NO;
    [moviePlayer prepareToPlay];
    [moviePlayer readyForDisplay];
    [moviePlayer setControlStyle:MPMovieControlStyleDefault];
    
    moviePlayer.shouldAutoplay = NO;
    
    [vwMoviePlayer addSubview:moviePlayer.view];
    [vwMoviePlayer setHidden:NO];
}

@end
