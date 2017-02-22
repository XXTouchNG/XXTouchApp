//
//  XXNavigationViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import "XXNavigationViewController.h"
#import "XXMainTabbarViewController.h"
#import "XXScriptListTableViewController.h"
#import "XXScanViewController.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

#define kXXCheckUpdateDailyIgnore @"kXXCheckUpdateDailyIgnore-%@"
#define kXXCheckUpdateVersionIgnore @"kXXCheckUpdateVersionIgnore-%@"

@interface XXNavigationViewController ()

@end

@implementation XXNavigationViewController

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[AppDelegate globalDelegate] setRootViewController:self];
    if (daemonInstalled()) {
        [self checkNeedsRespring];
    }
}

- (void)checkNeedsRespring {
    self.view.backgroundColor = [UIColor whiteColor];
    if (needsRespring()) {
        self.view.userInteractionEnabled = NO;
        @weakify(self);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Needs Respring", nil) andMessage:NSLocalizedString(@"You should resping your device to continue to use this application.", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"Respring Now", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            [self.view makeToastActivity:CSToastPositionCenter];
            [XXLocalNetService killBackboardd];
        }];
        [alertView show];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self checkUpdate];
        });
    }
}

- (NSArray <NSNumber *> *)versionArrayFromVersionString:(NSString *)versionString {
    NSUInteger majorVersion = 0, middleVersion = 0, minorVersion = 0, buildVersion = 0;
    NSArray <NSString *> *buildVersionArray = [versionString componentsSeparatedByString:@"-"];
    if (buildVersionArray.count == 2) {
        buildVersion = [buildVersionArray[1] unsignedIntegerValue];
    }
    NSArray <NSString *> *versionArray = [buildVersionArray[0] componentsSeparatedByString:@"."];
    if (versionArray.count >= 1) {
        majorVersion = [versionArray[0] unsignedIntegerValue];
    }
    if (versionArray.count >= 2) {
        middleVersion = [versionArray[1] unsignedIntegerValue];
    }
    if (versionArray.count >= 3) {
        minorVersion = [versionArray[2] unsignedIntegerValue];
    }
    return @[@(majorVersion), @(middleVersion), @(minorVersion), @(buildVersion)];
}

- (void)checkUpdate {
    NSString *currentVersion = extendDict()[@"daemonVersion"];
    if (!currentVersion) {
        return;
    }
    NSString *todayString = [[[XXLocalDataService sharedInstance] miniDateFormatter] stringFromDate:[NSDate date]];
    NSString *dailyIgnoreKey = [NSString stringWithFormat:kXXCheckUpdateDailyIgnore, todayString];
    if ([[XXLocalDataService sharedInstance] objectForKey:dailyIgnoreKey])
    {
        // Do not check today
        return;
    }
    NSError *error = nil;
    NSString *networkVersion = [XXLocalNetService latestVersionFromRepositoryPackagesWithError:&error];
    CYLog(@"Current Version: %@\nNetwork Version: %@", currentVersion, networkVersion);
    if (error) {
        dispatch_async_on_main_queue(^{
            [self.view makeToast:[error localizedDescription]];
        });
        return;
    }
    if (!networkVersion) {
        // Mal-formed Packages
        return;
    }
    BOOL shouldUpdate = NO;
    NSArray <NSNumber *> *networkVersionArray = [self versionArrayFromVersionString:networkVersion];
    NSArray <NSNumber *> *currentVersionArray = [self versionArrayFromVersionString:currentVersion];
    for (NSUInteger i = 0; i < networkVersionArray.count; i++) {
        if (
            [networkVersionArray[i] compare:currentVersionArray[i]] == NSOrderedDescending
            ) {
            shouldUpdate = YES;
            break;
        }
    }
    if (!shouldUpdate) {
        return;
    }
    NSString *versionIgnoreKey = [NSString stringWithFormat:kXXCheckUpdateVersionIgnore, networkVersion];
    if ([[XXLocalDataService sharedInstance] objectForKey:versionIgnoreKey])
    {
        // Do not notify version
        return;
    }
    dispatch_async_on_main_queue(^{
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Check Update", nil)
                                                     andMessage:[NSString stringWithFormat:NSLocalizedString(@"New version available: %@\nCurrent Version: %@", nil), networkVersion, currentVersion]];
        [alert addButtonWithTitle:NSLocalizedString(@"Update Now", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              NSURL *cydiaURL = [NSURL URLWithString:CYDIA_URL];
                              if ([[UIApplication sharedApplication] canOpenURL:cydiaURL]) {
                                  [[UIApplication sharedApplication] openURL:cydiaURL];
                              } else {
                                  [self.view makeToast:NSLocalizedString(@"Failed to open Cydia", nil)];
                              }
                          }];
        [alert addButtonWithTitle:NSLocalizedString(@"Tell Me Later", nil)
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [[XXLocalDataService sharedInstance] setObject:@(1) forKey:dailyIgnoreKey];
                          }];
        [alert addButtonWithTitle:NSLocalizedString(@"Ignore This Version", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              [[XXLocalDataService sharedInstance] setObject:@(1) forKey:versionIgnoreKey];
                          }];
        [alert show];
        [self performSelector:@selector(autodismissUpdateAlertView:) withObject:alert afterDelay:10.f];
    });
}

- (void)autodismissUpdateAlertView:(SIAlertView *)alertView {
    [alertView dismissAnimated:YES];
    [self.view makeToast:NSLocalizedString(@"Dismissed automatically", nil)];
}

- (void)handleShortCut:(NSString *)type {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([type isEqualToString:@"Launch"]) {
            SendConfigAction([XXLocalNetService localLaunchSelectedScriptWithError:&err], nil);
        } else if ([type isEqualToString:@"Stop"]) {
            SendConfigAction([XXLocalNetService localStopCurrentRunningScriptWithError:&err], nil);
        } else if ([type isEqualToString:@"Scan"]) {
            dispatch_async_on_main_queue(^{
                [self transitionToScanViewController];
            });
        }
    });
}

- (void)handleItemTransfer:(NSURL *)url {
    @weakify(self);
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity:CSToastPositionCenter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        NSString *lastComponent = [url lastPathComponent];
        NSString *formerPath = [url path];
        NSString *latterPath = [ROOT_PATH stringByAppendingPathComponent:lastComponent];
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:formerPath toPath:latterPath error:&err];
        dispatch_async_on_main_queue(^{
            self.view.userInteractionEnabled = YES;
            [self.view hideToastActivity];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kXXGlobalNotificationName object:nil userInfo:@{kXXGlobalNotificationKeyEvent: kXXGlobalNotificationKeyEventTransfer}]];
            if (result && err == nil) {
                [self.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"File \"%@\" saved", nil), lastComponent]];
            } else {
                [self.view makeToast:[err localizedDescription]];
            }
        });
    });
}

- (void)transitionToScanViewController {
    XXScanViewController *scanController = [[XXScanViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scanController];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
