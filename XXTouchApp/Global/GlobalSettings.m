//
//  GlobalSettings.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "GlobalSettings.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"
#import "XXQuickLookService.h"
#import "UMMobClick/MobClick.h"
#import "CloudApiSdk.h"

static NSString * const kXXTouchStorageDB = @"kXXTouchStorageDB-1";

@implementation GlobalSettings

+ (id)sharedInstance {
    static GlobalSettings *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupShortcutItems];
        [self setupDataService];
        [self setupStyle];
        [self setupMedia];
        [self setupStatistics];
    }
    return self;
}

- (void)setupDataService {
    self.dataService = [[XXLocalDataService alloc] initWithName:kXXTouchStorageDB];
}

- (void)setupStyle {
//    [UITextField appearanceWhenContainedIn:[UISearchBar class], nil].leftView = nil;
    
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setDefaultDuration:2.f];
    [CSToastManager setQueueEnabled:NO];
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    
    [CSToastManager sharedStyle].backgroundColor = [UIColor colorWithWhite:0.f alpha:.6f];
    [CSToastManager sharedStyle].titleFont = [UIFont boldSystemFontOfSize:14.f];
    [CSToastManager sharedStyle].messageFont = [UIFont systemFontOfSize:14.f];
    [CSToastManager sharedStyle].activitySize = CGSizeMake(80.f, 80.f);
    [CSToastManager sharedStyle].verticalMargin = 16.f;
    
    [SIAlertView appearance].transitionStyle = SIAlertViewTransitionStyleBounce;
    [SIAlertView appearance].backgroundStyle = SIAlertViewBackgroundStyleSolid;
    [SIAlertView appearance].titleFont = [UIFont boldSystemFontOfSize:18.f];
    [SIAlertView appearance].messageFont = [UIFont systemFontOfSize:14.f];
    [SIAlertView appearance].buttonFont = [UIFont systemFontOfSize:14.f];
}

- (void)setupMedia {
    
}

- (void)setupStatistics {
    UMConfigInstance.appKey = extendDict()[@"UMENG_KEY"];
    UMConfigInstance.channelId = extendDict()[@"CHANNEL_ID"];
    
    [MobClick startWithConfigure:UMConfigInstance];
    
    [[AppConfiguration instance] setAPP_KEY:extendDict()[@"ALIYUN_APPKEY"]];
    [[AppConfiguration instance] setAPP_SECRET:extendDict()[@"ALIYUN_APPSECRERT"]];
    [[AppConfiguration instance] setAPP_CONNECTION_TIMEOUT:[extendDict()[@"APP_CONNECTION_TIMEOUT"] intValue]];
}

- (void)setupShortcutItems {
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        return;
    }
    if (daemonInstalled()) {
        UIApplicationShortcutIcon *stopIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3d-stop"];
        UIApplicationShortcutItem *stopItem = [[UIApplicationShortcutItem alloc] initWithType:@"Stop"
                                                                               localizedTitle:NSLocalizedString(@"Stop", nil)
                                                                            localizedSubtitle:nil
                                                                                         icon:stopIcon
                                                                                     userInfo:@{@"firstShorcutKey3": @"firstShortcutKeyValue3"}];
        UIApplicationShortcutIcon *launchIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3d-launch"];
        UIApplicationShortcutItem *launchItem = [[UIApplicationShortcutItem alloc] initWithType:@"Launch"
                                                                                 localizedTitle:NSLocalizedString(@"Launch", nil)
                                                                              localizedSubtitle:nil
                                                                                           icon:launchIcon
                                                                                       userInfo:@{@"firstShorcutKey2": @"firstShortcutKeyValue2"}];
        UIApplicationShortcutIcon *scanIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3d-scan"];
        UIApplicationShortcutItem *scanItem = [[UIApplicationShortcutItem alloc] initWithType:@"Scan"
                                                                               localizedTitle:NSLocalizedString(@"Scan QR Code", nil)
                                                                            localizedSubtitle:nil
                                                                                         icon:scanIcon
                                                                                     userInfo:@{@"firstShorcutKey1": @"firstShortcutKeyValue1"}];
        [UIApplication sharedApplication].shortcutItems = @[stopItem, launchItem, scanItem];
    } else {
        [UIApplication sharedApplication].shortcutItems = @[];
    }
}

@end
