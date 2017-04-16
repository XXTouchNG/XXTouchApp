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
#import "Reachability.h"

#define commonHandler(command) \
^(SIAlertView *alertView) { \
    @strongify(self); \
    SendConfigAction(command, nil); \
}

#define alertViewConfirm(title, command) \
weakify(self); \
([alertView addButtonWithTitle:NSLocalizedString(title, nil) type:SIAlertViewButtonTypeDestructive handler:commonHandler(command)]);

enum {
    kRemoteSection  = 0,
    kServiceSection = 1,
    kAuthSection    = 2,
    kConfigSection  = 3,
    kSystemSection  = 4,
    kHelpSection    = 5,
};

// Index - kRemoteSection
enum {
    kServiceRemoteSwitchIndex = 0,
    kServiceRemoteAddressAIndex = 1,
    kServiceRemoteAddressBIndex = 2
};

// Index - kServiceSection
enum {
    kServiceRestartIndex  = 0,
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
@property (weak, nonatomic) IBOutlet UISwitch *remoteAccessSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *restartIndicator;
@property (weak, nonatomic) IBOutlet UILabel *remoteAccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteAddressLabelA;
@property (weak, nonatomic) IBOutlet UILabel *remoteAddressLabelB;


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
    
    [self fetchRemoteAccessStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateRemoteAccessUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchRemoteAccessStatus {
    self.remoteAccessSwitch.enabled = NO;
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localGetRemoteAccessStatusWithError:&err];
        dispatch_async_on_main_queue(^{
            if (!result) {
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                [self updateRemoteAccessUI];
            }
            self.remoteAccessSwitch.enabled = YES;
        });
    });
}

- (IBAction)remoteAccessSwitched:(UISwitch *)sender {
    BOOL status = [XXTGSSI.dataService remoteAccessStatus];
    if (sender.on) {
        if (!status) {
            sender.enabled = NO;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @strongify(self);
                __block NSError *err = nil;
                BOOL result = [XXLocalNetService localOpenRemoteAccessWithError:&err];
                dispatch_async_on_main_queue(^{
                    if (!result) {
                        [self.navigationController.view makeToast:[err localizedDescription]];
                    } else {
                        [self updateRemoteAccessUI];
                    }
                    sender.enabled = YES;
                });
            });
        }
    } else {
        if (status) {
            sender.enabled = NO;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @strongify(self);
                __block NSError *err = nil;
                BOOL result = [XXLocalNetService localCloseRemoteAccessWithError:&err];
                dispatch_async_on_main_queue(^{
                    if (!result) {
                        [self.navigationController.view makeToast:[err localizedDescription]];
                    } else {
                        [self updateRemoteAccessUI];
                    }
                    sender.enabled = YES;
                });
            });
        }
    }
}

- (void)updateRemoteAccessUI {
    BOOL on = [XXTGSSI.dataService remoteAccessStatus];
    [self.remoteAccessSwitch setOn:on animated:YES];
    if (on) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == ReachableViaWiFi)
        {
            NSDictionary *remoteAccessDictionary = [XXTGSSI.dataService remoteAccessDictionary];
            if (remoteAccessDictionary) {
                self.remoteAccessLabel.text = NSLocalizedString(@"Remote Service", nil);
                self.remoteAddressLabelA.text = remoteAccessDictionary[@"webserver_url"];
                self.remoteAddressLabelB.text = remoteAccessDictionary[@"bonjour_webserver_url"];
            }
        } else {
            self.remoteAccessLabel.text = NSLocalizedString(@"Connect to Wi-Fi", nil);
            self.remoteAddressLabelA.text = @"";
            self.remoteAddressLabelB.text = @"";
        }
    } else {
        self.remoteAccessLabel.text = NSLocalizedString(@"Remote Service", nil);
        self.remoteAddressLabelA.text = @"";
        self.remoteAddressLabelB.text = @"";
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kRemoteSection) {
        if (self.remoteAddressLabelA.text.length != 0 &&
            self.remoteAddressLabelB.text.length != 0) {
            return 3;
        } else {
            return 1;
        }
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kRemoteSection:
            switch (indexPath.row) {
                case kServiceRemoteSwitchIndex:
                    break;
                case kServiceRemoteAddressAIndex:
                    [[UIPasteboard generalPasteboard] setString:self.remoteAddressLabelA.text];
                    [self.navigationController.view makeToast:NSLocalizedString(@"Copied to the clipboard", nil)];
                    break;
                case kServiceRemoteAddressBIndex:
                    [[UIPasteboard generalPasteboard] setString:self.remoteAddressLabelB.text];
                    [self.navigationController.view makeToast:NSLocalizedString(@"Copied to the clipboard", nil)];
                    break;
                default:
                    break;
            }
            break;
        case kServiceSection:
            switch (indexPath.row) {
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
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Restart Now", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              @strongify(self);
                              [self.restartIndicator startAnimating];
                              SendConfigAction([XXLocalNetService localRestartDaemonWithError:&err]; if (result) [self waitUntilDaemonUp], [self.restartIndicator stopAnimating]; [self.navigationController.view makeToast:NSLocalizedString(@"Operation completed", nil)]);
                          }];
    [alertView show];
}

- (void)cleanGPSCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clean GPS Caches", nil)
                                                     andMessage:NSLocalizedString(@"This operation will reset location caches.", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanGPSCachesWithError:&err]);
    [alertView show];
}

- (void)cleanUICachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clean UI Caches", nil)
                                                     andMessage:NSLocalizedString(@"This operation will kill all applications and reset icon caches.\nIt may cause icons to disappear.", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanUICachesWithError:&err]);
    [alertView show];
}

- (void)cleanAllCachesSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear All", nil)
                                                     andMessage:NSLocalizedString(@"This operation will kill all applications, and remove all documents and caches of them.", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    @alertViewConfirm(@"Clean Now", [XXLocalNetService localCleanAllCachesWithError:&err]);
    [alertView show];
}

- (void)respringIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Respring Confirm", nil)
                                                     andMessage:NSLocalizedString(@"Tap \"Respring Now\" to continue.", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    @alertViewConfirm(@"Respring Now", [XXLocalNetService localRespringDeviceWithError:&err]);
    [alertView show];
}

- (void)rebootIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Reboot Confirm", nil)
                                                     andMessage:NSLocalizedString(@"Tap \"Reboot Now\" to continue.", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    @alertViewConfirm(@"Reboot Now", [XXLocalNetService localRestartDeviceWithError:&err]);
    [alertView show];
}

- (void)openReferencesUrl {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedString(@"Documents", nil);
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
