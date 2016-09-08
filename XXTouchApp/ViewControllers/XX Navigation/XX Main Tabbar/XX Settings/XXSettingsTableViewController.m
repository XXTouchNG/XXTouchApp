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

@end

@implementation XXSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"More", @"XXTouch", nil); // Override
    self.clearsSelectionOnViewWillAppear = YES; // Override
    
    self.tableView.scrollIndicatorInsets =
    self.tableView.contentInset =
    UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                    break;
                case kSystemCleanUICachesIndex:
                    break;
                case kSystemCleanAllCachesIndex:
                    break;
                case kSystemDeviceRespringIndex:
                    [self respringIndexSelected];
                    break;
                case kSystemDeviceRestartIndex:
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

- (void)respringIndexSelected {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Respring Confirm", @"XXTouch", nil)
                                                     andMessage:NSLocalizedStringFromTable(@"Tap \"Respring Now\" to continue", @"XXTouch", nil)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Respring Now", @"XXTouch", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              [XXLocalNetService respringDevice];
                          }];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"XXTouch", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView show];
}

- (void)openReferencesUrl {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = NSLocalizedStringFromTable(@"Documents", @"XXTouch", nil);
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
