//
//  XXMediaActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXMediaActivity.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVKit/AVPlayerViewController.h>

@implementation XXMediaActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi" ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-media";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Open as Media", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-media"];
}

- (void)presentActivity
{
    [super presentActivity];
    UIViewController *viewController = self.baseController;
    NSURL *sourceMovieURL = self.fileURL;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // 7.x
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:sourceMovieURL];
        [viewController.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer]; // Its animation is different from AVPlayerViewController
    } else {
        // 8.0+
        AVPlayer *player = [[AVPlayer alloc] initWithURL:sourceMovieURL];
        AVPlayerViewController *moviePlayer = [[AVPlayerViewController alloc] init];
        moviePlayer.player = player;
        [viewController.navigationController presentViewController:moviePlayer animated:YES completion:nil];
    }
}

@end
