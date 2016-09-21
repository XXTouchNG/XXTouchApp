//
//  XXSettingsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSettingsTableViewController.h"
#import "XXWebViewController.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"
#import <MJRefresh/MJRefresh.h>

#define commonHandler(command) \
^(SIAlertView *alertView) { \
    @strongify(self); \
    SendConfigAction(command, nil); \
}

#define alertViewConfirm(title, command) \
weakify(self); \
([alertView addButtonWithTitle:NSLocalizedString(title, nil) type:SIAlertViewButtonTypeDestructive handler:commonHandler(command)]);

enum {
    kServiceSection = 0,
    kAuthSection    = 1,
    kConfigSection  = 2,
    kSystemSection  = 3,
    kHelpSection    = 4,
};

// Index - kServiceSection
enum {
    kServiceRemoteSwitchIndex  = 0,
    kServiceRestartIndex = 1,
};

// Index - kAuthSection
enum {
    kAuthStatusIndex = 0,
};

// Index - kConfigSection
enum {
    kConfigActivationIndex = 0,
    kConfigRecordingIndex  = 1,
    kConfigLaunchingIndex  = 2,
    kConfigPreferenceIndex = 3,
};

// Index - kSystemSection
enum {
    kSystemApplicationListIndex = 0,
    kSystemCleanGPSStatusIndex  = 1,
    kSystemCleanUICachesIndex   = 2,
    kSystemCleanAllCachesIndex  = 3,
    kSystemDeviceRespringIndex  = 4,
    kSystemDeviceRestartIndex   = 5,
};

// Index - kHelpSection
enum {
    kHelpReferencesIndex = 0,
    kHelpAboutIndex      = 1,
};

@interface XXSettingsTableViewController ()
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;
@property (weak, nonatomic) IBOutlet UISwitch *remoteAccessSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *restartIndicator;
@property (weak, nonatomic) IBOutlet UILabel *remoteAccessLabel;

@end

@implementation XXSettingsTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"More", nil); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
    [self fetchRemoteAccessStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeRemoteAccessUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startMJRefreshing)];
        [normalHeader setTitle:NSLocalizedString(@"Pull down", nil) forState:MJRefreshStateIdle];
        [normalHeader setTitle:NSLocalizedString(@"Release", nil) forState:MJRefreshStatePulling];
        [normalHeader setTitle:NSLocalizedString(@"Loading...", nil) forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
            normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightThin];
        } else {
            normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0];
        }
        normalHeader.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)startMJRefreshing {
    [self fetchRemoteAccessStatus];
}

- (void)fetchRemoteAccessStatus {
    self.remoteAccessSwitch.enabled = NO;
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localGetRemoteAccessStatusWithError:&err];
        dispatch_async_on_main_queue(^{
            [self endMJRefreshing];
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self changeRemoteAccessUI];
            }
            self.remoteAccessSwitch.enabled = YES;
        });
    });
}

- (void)endMJRefreshing {
    if ([self.refreshHeader isRefreshing]) {
        [self.refreshHeader endRefreshing];
    }
}

- (IBAction)remoteAccessSwitched:(UISwitch *)sender {
    BOOL status = [[XXLocalDataService sharedInstance] remoteAccessStatus];
    if (sender.on) {
        if (!status) {
            self.remoteAccessSwitch.enabled = NO;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @strongify(self);
                __block NSError *err = nil;
                BOOL result = [XXLocalNetService localOpenRemoteAccessWithError:&err];
                dispatch_async_on_main_queue(^{
                    if (!result) {
                        [self.navigationController.view makeToast:[err localizedDescription]];
                    } else {
                        if ([self changeRemoteAccessUI]) {
                            NSURL *wifiPrefs = [NSURL URLWithString:@"prefs:root=WIFI"];
                            if ([[UIApplication sharedApplication] canOpenURL:wifiPrefs]) {
                                [[UIApplication sharedApplication] openURL:wifiPrefs];
                            }
                        }
                    }
                    self.remoteAccessSwitch.enabled = YES;
                });
            });
        }
    } else {
        if (status) {
            self.remoteAccessSwitch.enabled = NO;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @strongify(self);
                __block NSError *err = nil;
                BOOL result = [XXLocalNetService localCloseRemoteAccessWithError:&err];
                dispatch_async_on_main_queue(^{
                    if (!result) {
                        [self.navigationController.view makeToast:[err localizedDescription]];
                    } else {
                        [self changeRemoteAccessUI];
                    }
                    self.remoteAccessSwitch.enabled = YES;
                });
            });
        }
    }
}

- (BOOL)changeRemoteAccessUI {
    BOOL on = [[XXLocalDataService sharedInstance] remoteAccessStatus];
    [self.remoteAccessSwitch setOn:on animated:YES];
    if (on) {
        self.remoteAccessLabel.textColor = STYLE_TINT_COLOR;
        NSString *wifiAccess = [[XXLocalDataService sharedInstance] remoteAccessURL];
        if (wifiAccess == nil) {
            self.remoteAccessLabel.text = NSLocalizedString(@"Connect to Wi-Fi", nil);
            return YES;
        } else {
            self.remoteAccessLabel.text = wifiAccess;
        }
    } else {
        self.remoteAccessLabel.text = NSLocalizedString(@"Remote Service", nil);
        self.remoteAccessLabel.textColor = [UIColor blackColor];
    }
    return NO;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kServiceSection:
            switch (indexPath.row) {
                case kServiceRemoteSwitchIndex:
                    break;
                case kServiceRestartIndex:
                    [self restartServiceIndexSelected];
                    break;
                default:
                    break;
            }
            break;
        case kAuthSection:
            switch (indexPath.row) {
                case kAuthStatusIndex: // Next controller
                default:
                    break;
            }
            break;
        case kConfigSection:
            switch (indexPath.row) {
                case kConfigActivationIndex: // Next controller
                case kConfigRecordingIndex: // Next controller
                case kConfigLaunchingIndex: // Next controller
                case kConfigPreferenceIndex: // Next controller
                default:
                    break;
            }
            break;
        case kSystemSection:
            switch (indexPath.row) {
                case kSystemCleanGPSStatusIndex:
                    [self cleanGPSCachesSelected];
                    break;
                case kSystemCleanUICachesIndex:
                    [self cleanUICachesSelected];
                    break;
                case kSystemCleanAllCachesIndex:
                    [self cleanAllCachesSelected];
                    break;
                case kSystemDeviceRespringIndex:
                    [self respringIndexSelected];
                    break;
                case kSystemDeviceRestartIndex:
                    [self rebootIndexSelected];
                    break;
                case kSystemApplicationListIndex: // Next controller
                default:
                    break;
            }
            break;
        case kHelpSection:
            switch (indexPath.row) {
                case kHelpReferencesIndex: // Next Controller
                case kHelpAboutIndex: // Next controller
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)waitUntilDaemonUp {
    sleep(3);
    NSError *err = nil;
    BOOL detect = [XXLocalNetService localGetSelectedScriptWithError:&err];
    if (!detect) {
        sleep(1);
        [self waitUntilDaemonUp];
    }
}

- (void)restartServiceIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Restart Daemon", nil)
                                                     andMessage:NSLocalizedString(@"This operation will restart daemon, and wait until it launched.", nil)];
    @weakify(self);
    [alertView addButtonWithTitle:NSLocalizedString(@"Restart Now", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              @strongify(self);
                              [self.restartIndicator startAnimating];
                              SendConfigAction([XXLocalNetService localRestartDaemonWithError:&err]; if (result) [self waitUntilDaemonUp], [self.restartIndicator stopAnimating]; [self.navigationController.view makeToast:NSLocalizedString(@"Operation completed", nil)]);
                          }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanGPSCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clean GPS Caches", nil)
                                                     andMessage:NSLocalizedString(@"This operation will reset location caches.", nil)];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanGPSCachesWithError:&err]);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanUICachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clean UI Caches", nil)
                                                     andMessage:NSLocalizedString(@"This operation will kill all applications and reset icon caches.\nIt may cause icons to disappear.", nil)];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanUICachesWithError:&err]);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanAllCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear All", nil)
                                                     andMessage:NSLocalizedString(@"This operation will kill all applications, and remove all documents and caches of them.", nil)];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanAllCachesWithError:&err]);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)respringIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Respring Confirm", nil)
                                                     andMessage:NSLocalizedString(@"Tap \"Respring Now\" to continue.", nil)];
    @alertViewConfirm(@"Respring Now", [XXLocalNetService localRespringDeviceWithError:&err]);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)rebootIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Reboot Confirm", nil)
                                                     andMessage:NSLocalizedString(@"Tap \"Reboot Now\" to continue.", nil)];
    @alertViewConfirm(@"Reboot Now", [XXLocalNetService localRestartDeviceWithError:&err]);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)openReferencesUrl {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedString(@"Documents", nil);
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
