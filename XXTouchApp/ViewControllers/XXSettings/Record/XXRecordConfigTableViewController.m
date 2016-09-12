//
//  XXRecordConfigTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXRecordConfigTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"

enum {
    kXXRecordConfigRecordBothIndex = 0,
    kXXRecordConfigRecordVolumeUpIndex,
    kXXRecordConfigRecordVolumeDownIndex,
    kXXRecordConfigRecordNoneIndex
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
            [self loadRecordConfig]; \
        } \
    }); \
});

#define SendDoubleConfigAction(command1, command2) \
self.navigationController.view.userInteractionEnabled = NO; \
[self.navigationController.view makeToastActivity:CSToastPositionCenter]; \
@weakify(self); \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ \
    @strongify(self); \
    __block NSError *err = nil; \
    BOOL result = command1; \
    if (result) result = command2; \
    dispatch_async_on_main_queue(^{ \
        self.navigationController.view.userInteractionEnabled = YES; \
        [self.navigationController.view hideToastActivity]; \
        if (!result) { \
            [self.navigationController.view makeToast:[err localizedDescription]]; \
        } else { \
            [self loadRecordConfig]; \
        } \
    }); \
});

@interface XXRecordConfigTableViewController ()

@end

@implementation XXRecordConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SendConfigAction([XXLocalNetService localGetRecordConfWithError:&err]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)loadRecordConfig {
    XXLocalDataService *sharedInstance = [XXLocalDataService sharedInstance];
    BOOL volUp = [sharedInstance recordConfigRecordVolumeUp];
    BOOL volDown = [sharedInstance recordConfigRecordVolumeDown];
    
    if (volUp && volDown) {
        [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:kXXRecordConfigRecordBothIndex inSection:0]];
    } else if (volUp) {
        [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:kXXRecordConfigRecordVolumeUpIndex inSection:0]];
    } else if (volDown) {
        [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:kXXRecordConfigRecordVolumeDownIndex inSection:0]];
    } else {
        [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:kXXRecordConfigRecordNoneIndex inSection:0]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == kXXRecordConfigRecordBothIndex) {
            SendDoubleConfigAction([XXLocalNetService localSetRecordVolumeUpOnWithError:&err], [XXLocalNetService localSetRecordVolumeDownOnWithError:&err]);
        } else if (indexPath.row == kXXRecordConfigRecordVolumeUpIndex) {
            SendDoubleConfigAction([XXLocalNetService localSetRecordVolumeUpOnWithError:&err], [XXLocalNetService localSetRecordVolumeDownOffWithError:&err]);
        } else if (indexPath.row == kXXRecordConfigRecordVolumeDownIndex) {
            SendDoubleConfigAction([XXLocalNetService localSetRecordVolumeDownOnWithError:&err], [XXLocalNetService localSetRecordVolumeUpOffWithError:&err]);
        } else if (indexPath.row == kXXRecordConfigRecordNoneIndex) {
            SendDoubleConfigAction([XXLocalNetService localSetRecordVolumeUpOffWithError:&err], [XXLocalNetService localSetRecordVolumeDownOffWithError:&err]);
        }
    }
}

@end
