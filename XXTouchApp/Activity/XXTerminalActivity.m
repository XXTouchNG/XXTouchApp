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
#import "XXPaymentActivity.h"

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

- (UIViewController *)activityViewController
{
    XXTerminalViewController *terminalController = [[XXTerminalViewController alloc] init];
    terminalController.filePath = [self.fileURL path];
    terminalController.activity = self;
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:terminalController];
    return navController;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
