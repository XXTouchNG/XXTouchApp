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
    self.navigationController.view.userInteractionEnabled = NO; \
    [self.navigationController.view makeToastActivity:CSToastPositionCenter]; \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ \
        BOOL result = command; \
        dispatch_async_on_main_queue(^{ \
            self.navigationController.view.userInteractionEnabled = YES; \
            [self.navigationController.view hideToastActivity]; \
            if (!result) { \
                [self.navigationController.view makeToast:[err localizedDescription]]; \
            } \
        }); \
    }); \
}

#define alertViewConfirm(title, command) \
weakify(self); \
([alertView addButtonWithTitle:XXLString(title) type:SIAlertViewButtonTypeDestructive handler:commonHandler(command)]);

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = XXLString(@"More"); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    self.tableView.mj_header = self.refreshHeader;
    [self.refreshHeader beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startMJRefreshing)];
        [normalHeader setTitle:XXLString(@"Pull down") forState:MJRefreshStateIdle];
        [normalHeader setTitle:XXLString(@"Release") forState:MJRefreshStatePulling];
        [normalHeader setTitle:XXLString(@"Loading...") forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.hidden = YES;
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
        BOOL result = [[XXLocalNetService sharedInstance] localGetRemoteAccessStatusWithError:&err];
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
                BOOL result = [[XXLocalNetService sharedInstance] localOpenRemoteAccessWithError:&err];
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
                BOOL result = [[XXLocalNetService sharedInstance] localCloseRemoteAccessWithError:&err];
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
            self.remoteAccessLabel.text = XXLString(@"Connect to Wi-Fi");
            return YES;
        } else {
            self.remoteAccessLabel.text = [XXLString(@"Access via ") stringByAppendingString:wifiAccess];
        }
    } else {
        self.remoteAccessLabel.text = XXLString(@"Remote Service");
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
    BOOL detect = [[XXLocalNetService sharedInstance] localGetSelectedScriptWithError:&err];
    if (!detect) {
        sleep(1);
        [self waitUntilDaemonUp];
    }
}

- (void)restartServiceIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Restart Daemon")
                                                     andMessage:XXLString(@"This operation will restart daemon, and wait until it launched.")];
    @weakify(self);
    [alertView addButtonWithTitle:XXLString(@"Restart Now")
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              @strongify(self);
                              [self.restartIndicator startAnimating];
                              self.navigationController.view.userInteractionEnabled = NO;
                              [self.navigationController.view makeToastActivity:CSToastPositionCenter];
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                  __block NSError *err = nil;
                                  BOOL result = [[XXLocalNetService sharedInstance] localRestartDaemonWithError:&err];
                                  if (result) {
                                      [self waitUntilDaemonUp];
                                  }
                                  dispatch_async_on_main_queue(^{
                                      [self.restartIndicator stopAnimating];
                                      self.navigationController.view.userInteractionEnabled = YES;
                                      [self.navigationController.view hideToastActivity];
                                      if (!result) {
                                          [self.navigationController.view makeToast:[err localizedDescription]];
                                      } else {
                                          [self.navigationController.view makeToast:XXLString(@"Operation completed")];
                                      }
                                  });
                              });
                          }];
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanGPSCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean GPS Caches")
                                                     andMessage:XXLString(@"This operation will reset location caches.")];
    __block NSError *err = nil;
    @alertViewConfirm(@"Clean Now", [[XXLocalNetService sharedInstance] localCleanGPSCachesWithError:&err]);
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanUICachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean UI Caches")
                                                     andMessage:XXLString(@"This operation will kill all applications and reset icon caches.\nIt may cause icons to disappear.")];
    __block NSError *err = nil;
    @alertViewConfirm(@"Clean Now", [[XXLocalNetService sharedInstance] localCleanUICachesWithError:&err]);
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)cleanAllCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Clean All Caches")
                                                     andMessage:XXLString(@"This operation will kill all applications, and remove all documents and caches of them.")];
    __block NSError *err = nil;
    @alertViewConfirm(@"Clean Now", [[XXLocalNetService sharedInstance] localCleanAllCachesWithError:&err]);
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)respringIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Respring Confirm")
                                                     andMessage:XXLString(@"Tap \"Respring Now\" to continue.")];
    __block NSError *err = nil;
    @alertViewConfirm(@"Respring Now", [[XXLocalNetService sharedInstance] localRespringDeviceWithError:&err]);
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)rebootIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Reboot Confirm")
                                                     andMessage:XXLString(@"Tap \"Reboot Now\" to continue.")];
    __block NSError *err = nil;
    @alertViewConfirm(@"Reboot Now", [[XXLocalNetService sharedInstance] localRestartDeviceWithError:&err]);
    [alertView addButtonWithTitle:XXLString(@"Cancel")
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)openReferencesUrl {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = XXLString(@"Documents");
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
