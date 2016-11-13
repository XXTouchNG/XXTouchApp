//
//  XXTerminalActivity.m
//  XXTouchApp
//
//  Created by Zheng on 10/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXTerminalActivity.h"
#import "XXPaymentActivity.h"
#import "XXTerminalViewController.h"
#import "XXEmptyNavigationController.h"
#import "XXLocalDataService.h"

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

- (void)presentActivity
{
    [super presentActivity];
    if ([[XXLocalDataService sharedInstance] purchasedProduct]) {
        UIViewController *viewController = self.baseController;
        XXTerminalViewController *terminalController = [[XXTerminalViewController alloc] init];
        terminalController.filePath = [self.fileURL path];
        terminalController.title = [self.fileURL lastPathComponent];
        XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:terminalController];
        [viewController.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        XXPaymentActivity *act = [[XXPaymentActivity alloc] initWithViewController:self.baseController];
        [act presentActivity];
    }
}

@end
