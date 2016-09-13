//
//  XXUserDefaultsConfigTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXUserDefaultsConfigTableViewController.h"
#import "XXUserDefaultsConfigTableViewCell.h"
#import "XXUserDefaultsConfigOptionTableViewController.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

static NSString * const kXXUserDefaultsConfigTableViewCellIReuseIdentifier = @"kXXUserDefaultsConfigTableViewCellIReuseIdentifier";

@interface XXUserDefaultsConfigTableViewController ()
@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *userConfigArray;

@end

@implementation XXUserDefaultsConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES; // Override
    SendConfigAction([XXLocalNetService localGetUserConfWithError:&err], [self reloadConfigList]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadConfigList];
}

- (NSMutableArray <NSMutableDictionary *> *)userConfigArray {
    if (!_userConfigArray) {
        _userConfigArray = [[NSMutableArray alloc] init];
    }
    return _userConfigArray;
}

- (void)reloadConfigList {
    [self.userConfigArray removeAllObjects];
    NSDictionary *config = [[XXLocalDataService sharedInstance] userConfig];
    NSArray <NSString *> *allKeys = [config allKeysSorted];
    for (NSString *cKey in allKeys) {
        NSNumber *cVal = [config objectForKey:cKey];
        NSString *title = [self fetchTitleForKey:cKey];
        NSString *description = [self fetchDescriptionForKey:cKey];
        NSArray *choices = [self fetchChoicesForKey:cKey];
        if (!title || !description || !choices) continue;
        [self.userConfigArray addObject:[[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                          kXXUserDefaultsConfigTitle: title,
                                                                                          kXXUserDefaultsConfigDescription: description,
                                                                                          kXXUserDefaultsConfigChoices: choices,
                                                                                          kXXUserDefaultsConfigKey: cKey,
                                                                                          kXXUserDefaultsConfigValue: cVal,
                                                                                          }]];
    }
    [self.tableView reloadData];
}

- (NSString *)fetchTitleForKey:(NSString *)key {
    NSDictionary *titleKey = @{
                               @"no_nosim_alert": XXLString(@"Hide \"No SIM\" Alert"),
                               @"no_low_power_alert": XXLString(@"Hide \"Low Power\" Alert"),
                               @"no_idle": XXLString(@"Disable Auto-Lock"),
                               @"script_on_daemon": XXLString(@"Enable Daemon Mode"),
                               @"script_end_hint": XXLString(@"Enable Script Ended Toast"),
                               @"no_need_pushid_alert": XXLString(@"Hide \"Connect to iTunes to Use Push Notifications\" Alert"),
                               @"no_nosim_statusbar": XXLString(@"Hide \"No SIM\" On Status Bar"),
                               @"use_classic_control_alert": XXLString(@"Use Classical Alert View"),
                               };
    return [titleKey objectForKey:key];
}

- (NSString *)fetchDescriptionForKey:(NSString *)key {
    NSDictionary *descriptionKey = @{
                                     @"no_nosim_alert": XXLString(@"Prevent \"No SIM\" alert from showing"),
                                     @"no_low_power_alert": XXLString(@"Prevent \"Low Power\" alert from showing"),
                                     @"no_idle": XXLString(@"Prevent device from auto-screen lock"),
                                     @"script_on_daemon": XXLString(@"Launch the last executed script again if the daemon quitted unexpectedly"),
                                     @"script_end_hint": XXLString(@"Show \"Script stopped\" hint"),
                                     @"no_need_pushid_alert": XXLString(@"Prevent \"Connect to iTunes to Use Push Notifications\" alert from showing"),
                                     @"no_nosim_statusbar": XXLString(@"Prevent \"No SIM\" text on status bar from displaying"),
                                     @"use_classic_control_alert": XXLString(@"Use classical alert view instead of animated SIAlertView"),
                                     };
    return [descriptionKey objectForKey:key];
}

- (NSArray *)fetchChoicesForKey:(NSString *)key {
    NSDictionary *choicesKey = @{
                                     @"no_nosim_alert": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"no_low_power_alert": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"no_idle": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"script_on_daemon": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"script_end_hint": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"no_need_pushid_alert": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"no_nosim_statusbar": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     @"use_classic_control_alert": @[XXLString(@"Enable"), XXLString(@"Disable")],
                                     };
    return [choicesKey objectForKey:key];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 66;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.userConfigArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXUserDefaultsConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXUserDefaultsConfigTableViewCellIReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.configInfo = self.userConfigArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(XXUserDefaultsConfigTableViewCell *)sender {
    ((XXUserDefaultsConfigOptionTableViewController *)segue.destinationViewController).configInfo = sender.configInfo;
}

@end
