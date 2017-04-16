//
//  XXKeyPressConfigActionTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/12/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyPressConfigActionTableViewController.h"
#import "XXKeyPressConfigOperationTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import <objc/runtime.h>	
#import "libactivator.h"
#import <dlfcn.h>

typedef enum : NSUInteger {
    kXXActivatorListenerRunOrStopWithAlertIndex = 0,
    kXXActivatorListenerRunOrStopIndex = 1,
} kXXActivatorListenerIndex;

static NSString * const kXXActivatorLibraryPath = @"/usr/lib/libactivator.dylib";
static NSString * const kXXActivatorListenerRunOrStop = @"com.1func.xxtouch.run_or_stop";
static NSString * const kXXActivatorListenerRunOrStopWithAlert = @"com.1func.xxtouch.run_or_stop_with_alert";
static void * handle = nil;

@interface XXKeyPressConfigActionTableViewController ()
@property (nonatomic, assign) BOOL activatorExists;

@end

@implementation XXKeyPressConfigActionTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    if ([[NSFileManager defaultManager] fileExistsAtPath:kXXActivatorLibraryPath]) {
        handle = dlopen([kXXActivatorLibraryPath UTF8String], RTLD_LAZY);
        Class la = objc_getClass("LAActivator");
        if (!la) {
            fprintf(stderr, "%s\n", dlerror());
            return;
        }
        dlerror();
        LAActivator *sharedActivator = [la sharedInstance];
        BOOL hasSeen = [sharedActivator hasSeenListenerWithName:kXXActivatorListenerRunOrStop];
        if (hasSeen) {
            self.activatorExists = YES;
        }
    } else {
        self.activatorExists = NO;
        SendConfigAction([XXLocalNetService localGetVolumeActionConfWithError:&err], [self reloadCheckmark]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSUInteger row = [self.tableView indexPathForCell:sender].row;
    XXKeyPressConfigOperationTableViewController *destinationController = segue.destinationViewController;
    if (row == kXXKeyPressConfigPressVolumeUpSection) {
        destinationController.title = NSLocalizedString(@"Up Press", nil);
        destinationController.operationDescription = NSLocalizedString(@"Press Volume Up Button", nil);
    } else if (row == kXXKeyPressConfigPressVolumeDownSection) {
        destinationController.title = NSLocalizedString(@"Down Press", nil);
        destinationController.operationDescription = NSLocalizedString(@"Press Volume Down Button", nil);
    } else if (row == kXXKeyPressConfigHoldVolumeUpSection) {
        destinationController.title = NSLocalizedString(@"Up Short Hold", nil);
        destinationController.operationDescription = NSLocalizedString(@"Hold Volume Up Button", nil);
    } else if (row == kXXKeyPressConfigHoldVolumeDownSection) {
        destinationController.title = NSLocalizedString(@"Down Short Hold", nil);
        destinationController.operationDescription = NSLocalizedString(@"Hold Volume Down Button", nil);
    }
    destinationController.currentSection = row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.activatorExists) {
        return 2;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (self.activatorExists) {
            [self.navigationController.view makeToast:NSLocalizedString(@"Activator is installed, please turn to section below", nil)];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == kXXActivatorListenerRunOrStopWithAlertIndex) {
            LAListenerSettingsViewController *vc = [objc_getClass("LAListenerSettingsViewController") new];
            vc.listenerName = kXXActivatorListenerRunOrStopWithAlert;
            vc.title = NSLocalizedString(@"Pop-up menu", nil);
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == kXXActivatorListenerRunOrStopIndex) {
            LAListenerSettingsViewController *vc = [objc_getClass("LAListenerSettingsViewController") new];
            vc.listenerName = kXXActivatorListenerRunOrStop;
            vc.title = NSLocalizedString(@"Launch / Stop selected script", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)reloadCheckmark {
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender {
    if (self.activatorExists) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath.section == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    XXLog(@"");
}

@end
