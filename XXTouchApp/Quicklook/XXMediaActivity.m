//
//  XXMediaActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXMediaActivity.h"
#import "XXMediaViewController.h"
#import "XXEmptyNavigationController.h"

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

- (UIViewController *)activityViewController {
    XXMediaViewController *moviePlayerController = [[XXMediaViewController alloc] init];
    moviePlayerController.filePath = [self.fileURL path];
    moviePlayerController.activity = self;
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:moviePlayerController];
    return navController;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
