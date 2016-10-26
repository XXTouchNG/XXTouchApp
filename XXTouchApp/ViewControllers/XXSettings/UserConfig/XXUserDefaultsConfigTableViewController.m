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
#import "XXUserDefaultsModel.h"

#define USER_DEFAULTS_SWITCH_CHOICES @[NSLocalizedString(@"Disable", nil), NSLocalizedString(@"Enable", nil)]

typedef enum : NSUInteger {
    kXXUserDefaultsSectionLocalIndex = 0,
    kXXUserDefaultsSectionRemoteIndex = 1,
} kXXUserDefaultsSection;

static NSString * const kXXUserDefaultsConfigTableViewCellIReuseIdentifier = @"kXXUserDefaultsConfigTableViewCellIReuseIdentifier";

@interface XXUserDefaultsConfigTableViewController ()
@property (nonatomic, strong) NSMutableArray <XXUserDefaultsModel *> *remoteUserConfigArray;
@property (nonatomic, strong) NSMutableArray <XXUserDefaultsModel *> *localUserConfigArray;

@end

@implementation XXUserDefaultsConfigTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES; // Override
    SendConfigAction([XXLocalNetService localGetUserConfWithError:&err], [self reloadRemoteConfigList]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadLocalConfigList];
    [self reloadRemoteConfigList];
}

- (NSMutableArray <XXUserDefaultsModel *> *)localUserConfigArray {
    if (!_localUserConfigArray) {
        _localUserConfigArray = [[NSMutableArray alloc] init];
    }
    return _localUserConfigArray;
}

- (NSMutableArray <XXUserDefaultsModel *> *)remoteUserConfigArray {
    if (!_remoteUserConfigArray) {
        _remoteUserConfigArray = [[NSMutableArray alloc] init];
    }
    return _remoteUserConfigArray;
}

- (void)loadConfigListFromDictionary:(NSDictionary *)dict toArray:(NSMutableArray *)array {
    [array removeAllObjects];
    NSDictionary *config = dict;
    NSArray <NSString *> *allKeys = [config allKeysSorted];
    for (NSString *cKey in allKeys) {
        XXUserDefaultsModel *model = [XXUserDefaultsModel new];
        model.configTitle = [self fetchTitleForKey:cKey];
        if (model.configTitle == nil) {
            continue;
        }
        model.configDescription = [self fetchDescriptionForKey:cKey];
        model.configChoices = [self fetchChoicesForKey:cKey];
        model.configValue = [[config objectForKey:cKey] integerValue];
        model.configKey = [cKey copy];
        model.configType = [self fetchTypeForKey:cKey];
        [array addObject:model];
    }
}

- (void)reloadLocalConfigList {
    [self loadConfigListFromDictionary:[[XXLocalDataService sharedInstance] localUserConfig] toArray:self.localUserConfigArray];
    [self.tableView reloadData];
}

- (void)reloadRemoteConfigList {
    [self loadConfigListFromDictionary:[[XXLocalDataService sharedInstance] remoteUserConfig] toArray:self.remoteUserConfigArray];
    [self.tableView reloadData];
}

- (NSString *)fetchTitleForKey:(NSString *)key {
    NSDictionary *titleKey = @{
                               @"no_nosim_alert": NSLocalizedString(@"Hide \"No SIM\" Alert", nil),
                               @"no_low_power_alert": NSLocalizedString(@"Hide \"Low Power\" Alert", nil),
                               @"no_idle": NSLocalizedString(@"Insomnia Mode", nil),
                               @"script_on_daemon": NSLocalizedString(@"Daemon Mode", nil),
                               @"script_end_hint": NSLocalizedString(@"Script Ended Toast", nil),
                               @"no_need_pushid_alert": NSLocalizedString(@"Hide \"Connect to iTunes...\" Alert", nil),
                               @"no_nosim_statusbar": NSLocalizedString(@"Hide \"No SIM\" On Status Bar", nil),
                               @"use_classic_control_alert": NSLocalizedString(@"Use Classical Alert View", nil),
                               kXXLocalConfigHidesMainPath: NSLocalizedString(@"Hide \"Main Directory\" entry", nil),
                               };
    return [titleKey objectForKey:key];
}

- (NSString *)fetchDescriptionForKey:(NSString *)key {
    NSDictionary *descriptionKey = @{
                                     @"no_nosim_alert": NSLocalizedString(@"Prevent \"No SIM\" alert from showing", nil),
                                     @"no_low_power_alert": NSLocalizedString(@"Prevent \"Low Power\" alert from showing", nil),
                                     @"no_idle": NSLocalizedString(@"Prevent device from real sleep (offline)", nil),
                                     @"script_on_daemon": NSLocalizedString(@"Launch the last executed script again if the daemon quitted unexpectedly", nil),
                                     @"script_end_hint": NSLocalizedString(@"Show \"Script stopped\" hint", nil),
                                     @"no_need_pushid_alert": NSLocalizedString(@"Prevent \"Connect to iTunes to Use Push Notifications\" alert from showing", nil),
                                     @"no_nosim_statusbar": NSLocalizedString(@"Prevent \"No SIM\" text on status bar from displaying", nil),
                                     @"use_classic_control_alert": NSLocalizedString(@"Use classical alert view instead of animated SIAlertView", nil),
                                     kXXLocalConfigHidesMainPath: NSLocalizedString(@"Prevent \"Main Directory\" entry at the top of file explorer from showing", nil),
                                     };
    return [descriptionKey objectForKey:key];
}

- (NSArray *)fetchChoicesForKey:(NSString *)key {
    NSDictionary *choicesKey = @{
                                     @"no_nosim_alert": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"no_low_power_alert": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"no_idle": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"script_on_daemon": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"script_end_hint": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"no_need_pushid_alert": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"no_nosim_statusbar": USER_DEFAULTS_SWITCH_CHOICES,
                                     @"use_classic_control_alert": USER_DEFAULTS_SWITCH_CHOICES,
                                     kXXLocalConfigHidesMainPath: USER_DEFAULTS_SWITCH_CHOICES,
                                     };
    return [choicesKey objectForKey:key];
}

- (kXXUserDefaultsType)fetchTypeForKey:(NSString *)key {
    NSDictionary *typesKey = @{
                                 @"no_nosim_alert": @(kXXUserDefaultsTypeSwitch),
                                 @"no_low_power_alert": @(kXXUserDefaultsTypeSwitch),
                                 @"no_idle": @(kXXUserDefaultsTypeSwitch),
                                 @"script_on_daemon": @(kXXUserDefaultsTypeSwitch),
                                 @"script_end_hint": @(kXXUserDefaultsTypeSwitch),
                                 @"no_need_pushid_alert": @(kXXUserDefaultsTypeSwitch),
                                 @"no_nosim_statusbar": @(kXXUserDefaultsTypeSwitch),
                                 @"use_classic_control_alert": @(kXXUserDefaultsTypeSwitch),
                                 kXXLocalConfigHidesMainPath: @(kXXUserDefaultsTypeSwitch),
                                 };
    return [(NSNumber *)[typesKey objectForKey:key] integerValue];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kXXUserDefaultsSectionLocalIndex) {
        return NSLocalizedString(@"Application Preference", nil);
    } else if (section == kXXUserDefaultsSectionRemoteIndex) {
        return NSLocalizedString(@"Service Preference", nil);
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kXXUserDefaultsSectionLocalIndex) {
        return self.localUserConfigArray.count;
    } else if (section == kXXUserDefaultsSectionRemoteIndex) {
        return self.remoteUserConfigArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXUserDefaultsConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXUserDefaultsConfigTableViewCellIReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section == kXXUserDefaultsSectionLocalIndex) {
        cell.configInfo = self.localUserConfigArray[indexPath.row];
        cell.configInfo.isRemote = NO;
    } else if (indexPath.section == kXXUserDefaultsSectionRemoteIndex) {
        cell.configInfo = self.remoteUserConfigArray[indexPath.row];
        cell.configInfo.isRemote = YES;
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

- (void)dealloc {
    CYLog(@"");
}

@end
