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

@interface XXRecordConfigTableViewController ()
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation XXRecordConfigTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    SendConfigAction([XXLocalNetService localGetRecordConfWithError:&err], [self loadRecordConfig]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Static Cells
- (void)displayCheckmarkForIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i <= [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        if (i == indexPath.row) {
            _selectedIndex = i;
            cell.textLabel.textColor = STYLE_TINT_COLOR;
            if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            if (cell.accessoryType != UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [self.tableView reloadData];
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
    if (_selectedIndex != indexPath.row && indexPath.section == 0) {
        if (indexPath.row == kXXRecordConfigRecordBothIndex) {
            SendConfigAction([XXLocalNetService localSetRecordVolumeUpOnWithError:&err]; if (result) [XXLocalNetService localSetRecordVolumeDownOnWithError:&err], [self loadRecordConfig]);
        } else if (indexPath.row == kXXRecordConfigRecordVolumeUpIndex) {
            SendConfigAction([XXLocalNetService localSetRecordVolumeUpOnWithError:&err]; if (result) [XXLocalNetService localSetRecordVolumeDownOffWithError:&err], [self loadRecordConfig]);
        } else if (indexPath.row == kXXRecordConfigRecordVolumeDownIndex) {
            SendConfigAction([XXLocalNetService localSetRecordVolumeDownOnWithError:&err]; if (result) [XXLocalNetService localSetRecordVolumeUpOffWithError:&err], [self loadRecordConfig]);
        } else if (indexPath.row == kXXRecordConfigRecordNoneIndex) {
            SendConfigAction([XXLocalNetService localSetRecordVolumeUpOffWithError:&err]; if (result) [XXLocalNetService localSetRecordVolumeDownOffWithError:&err], [self loadRecordConfig]);
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSString *footerText = nil;
        if (_selectedIndex == 0) {
            footerText = NSLocalizedString(@"Both Volume + and Volume - button press operation will be recorded during recording process.", nil);
        } else if (_selectedIndex == 1) {
            footerText = NSLocalizedString(@"Only Volume + button press operation will be recorded during recording process.", nil);
        } else if (_selectedIndex == 2) {
            footerText = NSLocalizedString(@"Only Volume - button press operation will be recorded during recording process.", nil);
        } else if (_selectedIndex == 3) {
            footerText = NSLocalizedString(@"No volume button press operation will be recorded during recording process.", nil);
        }
        return footerText;
    }
    return nil;
}

- (void)dealloc {
    XXLog(@"");
}

@end
