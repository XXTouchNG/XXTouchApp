//
//  XXKeyPressConfigTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyPressConfigTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"

enum {
    kXXKeyPressConfigHoldVolumeUpSection = 0,
    kXXKeyPressConfigHoldVolumeDownSection,
    kXXKeyPressConfigPressVolumeUpSection,
    kXXKeyPressConfigPressVolumeDownSection,
};

#define SendConfigAction(command) \
self.navigationController.view.userInteractionEnabled = NO; \
[self.navigationController.view makeToastActivity:CSToastPositionCenter]; \
@weakify(self); \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ \
    @strongify(self); \
    __block NSError *err = nil; \
    BOOL result = command; \
    dispatch_async_on_main_queue(^{ \
        self.navigationController.view.userInteractionEnabled = YES; \
        [self.navigationController.view hideToastActivity]; \
        if (!result) { \
            [self.navigationController.view makeToast:[err localizedDescription]]; \
        } else { \
            [self loadKeyPressConfig]; \
        } \
    }); \
});

@interface XXKeyPressConfigTableViewController ()

@end

#warning check if activator is installed

@implementation XXKeyPressConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SendConfigAction([XXLocalNetService localGetVolumeActionConfWithError:&err]);
}

- (void)displayCheckmarkForIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i <= [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        if (i == indexPath.row) {
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            if (cell.accessoryType != UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
}

- (void)loadKeyPressConfig {
    XXLocalDataService *sharedInstance = [XXLocalDataService sharedInstance];
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:[sharedInstance keyPressConfigHoldVolumeUp] inSection:kXXKeyPressConfigHoldVolumeUpSection]];
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:[sharedInstance keyPressConfigHoldVolumeDown] inSection:kXXKeyPressConfigHoldVolumeDownSection]];
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:[sharedInstance keyPressConfigPressVolumeUp] inSection:kXXKeyPressConfigPressVolumeUpSection]];
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:[sharedInstance keyPressConfigPressVolumeDown] inSection:kXXKeyPressConfigPressVolumeDownSection]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kXXKeyPressConfigHoldVolumeUpSection) {
        SendConfigAction([XXLocalNetService localSetHoldVolumeUpAction:indexPath.row error:&err]);
    } else if (indexPath.section == kXXKeyPressConfigHoldVolumeDownSection) {
        SendConfigAction([XXLocalNetService localSetHoldVolumeDownAction:indexPath.row error:&err]);
    } else if (indexPath.section == kXXKeyPressConfigPressVolumeUpSection) {
        SendConfigAction([XXLocalNetService localSetPressVolumeUpAction:indexPath.row error:&err]);
    } else if (indexPath.section == kXXKeyPressConfigPressVolumeDownSection) {
        SendConfigAction([XXLocalNetService localSetPressVolumeDownAction:indexPath.row error:&err]);
    }
}

@end
