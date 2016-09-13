//
//  XXKeyPressConfigOperationTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/12/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyPressConfigOperationTableViewController.h"
#import "XXLocalNetService.h"

@interface XXKeyPressConfigOperationTableViewController ()
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation XXKeyPressConfigOperationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    [self reloadCheckmark];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_selectedIndex != indexPath.row && indexPath.section == 0) {
        if (self.currentSection == kXXKeyPressConfigHoldVolumeUpSection) {
            SendConfigAction([XXLocalNetService localSetHoldVolumeUpAction:indexPath.row error:&err], [self reloadCheckmark]);
        } else if (self.currentSection == kXXKeyPressConfigHoldVolumeDownSection) {
            SendConfigAction([XXLocalNetService localSetHoldVolumeDownAction:indexPath.row error:&err], [self reloadCheckmark]);
        } else if (self.currentSection == kXXKeyPressConfigPressVolumeUpSection) {
            SendConfigAction([XXLocalNetService localSetPressVolumeUpAction:indexPath.row error:&err], [self reloadCheckmark]);
        } else if (self.currentSection == kXXKeyPressConfigPressVolumeDownSection) {
            SendConfigAction([XXLocalNetService localSetPressVolumeDownAction:indexPath.row error:&err], [self reloadCheckmark]);
        }
    }
}

- (void)reloadCheckmark {
    kXXKeyPressConfig configValue = 0;
    if (self.currentSection == kXXKeyPressConfigHoldVolumeUpSection) {
        configValue = [[XXLocalDataService sharedInstance] keyPressConfigHoldVolumeUp];
    } else if (self.currentSection == kXXKeyPressConfigHoldVolumeDownSection) {
        configValue = [[XXLocalDataService sharedInstance] keyPressConfigHoldVolumeDown];
    } else if (self.currentSection == kXXKeyPressConfigPressVolumeUpSection) {
        configValue = [[XXLocalDataService sharedInstance] keyPressConfigPressVolumeUp];
    } else if (self.currentSection == kXXKeyPressConfigPressVolumeDownSection) {
        configValue = [[XXLocalDataService sharedInstance] keyPressConfigPressVolumeDown];
    }
    [self displayCheckmarkForIndexPath:[NSIndexPath indexPathForRow:configValue inSection:0]];
}

@end
