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
@property (strong, nonatomic) NSString *configTitle;
@property (strong, nonatomic) NSString *configDescription;
@property (strong, nonatomic) NSString *configKey;
@property (nonatomic, strong) NSArray <NSString *>* configArray;
@property (nonatomic, assign) NSInteger configIndex;

@end

@implementation XXUserDefaultsConfigOptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadConfigInfo];
}

- (void)loadConfigInfo {
    self.title =
    _configTitle = (NSString *)_configInfo[kXXUserDefaultsConfigTitle];
    _configDescription = (NSString *)_configInfo[kXXUserDefaultsConfigDescription];
    _configArray = (NSArray *)_configInfo[kXXUserDefaultsConfigChoices];
    _configIndex = [(NSNumber *)_configInfo[kXXUserDefaultsConfigValue] integerValue];
    _configKey = (NSString *)_configInfo[kXXUserDefaultsConfigKey];
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
    return _configArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return XXLString(@"User Defined Options");
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return _configDescription;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXUserDefaultsConfigOptionTableViewCellIReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == _configIndex) {
            cell.textLabel.textColor = STYLE_TINT_COLOR;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (_configArray.count > indexPath.row) {
            cell.textLabel.text = _configArray[indexPath.row];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (_configArray.count > indexPath.row) {
            if (_configIndex != indexPath.row) {
                _configIndex = indexPath.row;
                [_configInfo setObject:[NSNumber numberWithInteger:_configIndex] forKey:kXXUserDefaultsConfigValue];
                NSInteger choice = _configIndex;
                [[[XXLocalDataService sharedInstance] userConfig] setObject:[NSNumber numberWithInteger:choice] forKey:_configKey];
                SendConfigAction([XXLocalNetService localSetUserConfWithError:&err], [self loadConfigInfo]);
            }
        }
    }
}

@end
