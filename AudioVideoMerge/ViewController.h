//
//  ViewController.h
//  AudioVideoMerge
//
//  Created by TheAppGuruz-iOS-103 on 26/04/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController
{
    MPMoviePlayerController *moviePlayer;
}

- (IBAction)btnMergeTapped:(id)sender;

- (void)exportDidFinish:(AVAssetExportSession*)session;

@property(nonatomic,retain)AVURLAsset* videoAsset;
@property(nonatomic,retain)AVURLAsset* audioAsset;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIView *vwMoviePlayer;

@end
