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

static NSString * const tmpLockedItemPath = @"/private/var/tmp/1ferver_need_respring";

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
    [self checkNeedsRespring];
    [[AppDelegate globalDelegate] setRootViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkNeedsRespring {
    self.view.backgroundColor = [UIColor whiteColor];
    if ([FCFileManager existsItemAtPath:tmpLockedItemPath]) {
        self.view.userInteractionEnabled = NO;
        @weakify(self);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Needs Respring", nil) andMessage:NSLocalizedString(@"You should resping your device to continue to use this application.", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"Respring Now", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            [self.view makeToastActivity:CSToastPositionCenter];
            [XXLocalNetService killBackboardd];
        }];
        [alertView show];
    }
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
    UIViewController *topVC = self.topViewController;
    __block XXScriptListTableViewController *scriptController = nil;
    if ([topVC isMemberOfClass:[XXScriptListTableViewController class]]) {
        scriptController = (XXScriptListTableViewController *)topVC;
    } else if ([topVC isMemberOfClass:[XXMainTabbarViewController class]]) {
        scriptController = (XXScriptListTableViewController *)(((XXMainTabbarViewController *)topVC).viewControllers[0]);
    }
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        NSString *lastComponent = [url lastPathComponent];
        NSString *formerPath = [url path];
        NSString *latterPath = [ROOT_PATH stringByAppendingPathComponent:lastComponent];
        BOOL result = [FCFileManager moveItemAtPath:formerPath toPath:latterPath overwrite:NO error:&err];
        dispatch_async_on_main_queue(^{
            if ([scriptController respondsToSelector:@selector(reloadScriptListTableView)]) {
                [scriptController performSelector:@selector(reloadScriptListTableView) withObject:nil];
            }
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
