//
//  XXUserDefaultsConfigOptionTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXUserDefaultsConfigOptionTableViewController.h"
#import "XXUserDefaultsConfigTableViewCell.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

static NSString * const kXXUserDefaultsConfigOptionTableViewCellIReuseIdentifier = @"kXXUserDefaultsConfigOptionTableViewCellIReuseIdentifier";

@interface XXUserDefaultsConfigOptionTableViewController ()

@end

@implementation XXUserDefaultsConfigOptionTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadConfigInfo];
}

- (void)loadConfigInfo {
    self.title = _configInfo.configTitle;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _configInfo.configChoices.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (_configInfo.configType == kXXUserDefaultsTypeSwitch) {
            return NSLocalizedString(@"Switch", nil);
        } else if (_configInfo.configType == kXXUserDefaultsTypeChoice) {
            return NSLocalizedString(@"Choice", nil);
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return _configInfo.configDescription;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXUserDefaultsConfigOptionTableViewCellIReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == _configInfo.configValue) {
            cell.textLabel.textColor = STYLE_TINT_COLOR;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (_configInfo.configChoices.count > indexPath.row) {
            cell.textLabel.text = _configInfo.configChoices[indexPath.row];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (_configInfo.configChoices.count > indexPath.row) {
            if (_configInfo.configValue != indexPath.row) {
                _configInfo.configValue = indexPath.row;
                if (_configInfo.configType == kXXUserDefaultsTypeSwitch) {
                    if (_configInfo.configValue == YES) {
                        [[[XXLocalDataService sharedInstance] userConfig] setObject:@YES forKey:_configInfo.configKey];
                    } else {
                        [[[XXLocalDataService sharedInstance] userConfig] setObject:@NO forKey:_configInfo.configKey];
                    }
                } else if (_configInfo.configType == kXXUserDefaultsTypeChoice) {
                    [[[XXLocalDataService sharedInstance] userConfig] setObject:@(_configInfo.configValue) forKey:_configInfo.configKey];
                }
                SendConfigAction([XXLocalNetService localSetUserConfWithError:&err], [self loadConfigInfo]);
            }
        }
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
