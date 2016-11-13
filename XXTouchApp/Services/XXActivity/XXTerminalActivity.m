//
//  XXTerminalActivity.m
//  XXTouchApp
//
//  Created by Zheng on 10/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXTerminalActivity.h"
#import "XXTerminalViewController.h"
#import "XXEmptyNavigationController.h"

@implementation XXTerminalActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"lua" ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-terminal";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Run as Lua", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"action-play"];
}

- (void)performActivity
{
    UIViewController *viewController = self.baseController;
    XXTerminalViewController *terminalController = [[XXTerminalViewController alloc] init];
    terminalController.filePath = [self.fileURL path];
    terminalController.title = [self.fileURL lastPathComponent];
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:terminalController];
    [viewController.navigationController presentViewController:navController animated:YES completion:nil];
    [self activityDidFinish:YES];
}

@end
