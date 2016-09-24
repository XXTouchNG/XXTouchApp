//
//  XXLocalDataService.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>

typedef enum : NSUInteger {
    kXXPasteboardTypeCopy,
    kXXPasteboardTypeCut,
} kXXPasteboardType;

typedef enum : NSUInteger {
    kXXScriptListSortByModificationDesc = 0,
    kXXScriptListSortByNameAsc = 1,
} kXXScriptListSortMethod;

typedef enum : NSUInteger {
    kXXKeyPressConfigPopup,
    kXXKeyPressConfigSilence,
    kXXKeyPressConfigNoAction,
} kXXKeyPressConfig;

static NSString * const kXXDeviceInfoSoftwareVersion = @"zeversion";
static NSString * const kXXDeviceInfoSystemVersion = @"sysversion";
static NSString * const kXXDeviceInfoDeviceType = @"devtype";
static NSString * const kXXDeviceInfoDeviceName = @"devname";
static NSString * const kXXDeviceInfoSerialNumber = @"devsn";
static NSString * const kXXDeviceInfoMacAddress = @"devmac";
static NSString * const kXXDeviceInfoUniqueID = @"deviceid";
static NSString * const kXXDeviceInfoClientIP = @"ipaddr";
static NSString * const kXXDeviceInfoLocalIP = @"wifi_ip";
static NSString * const kXXDeviceInfoLocalPort = @"port";

static NSString * const kXXKeyPressConfigHoldVolumeUp = @"hold_volume_up";
static NSString * const kXXKeyPressConfigHoldVolumeDown = @"hold_volume_down";
static NSString * const kXXKeyPressConfigPressVolumeUp = @"click_volume_up";
static NSString * const kXXKeyPressConfigPressVolumeDown = @"click_volume_down";
static NSString * const kXXKeyPressConfigActivatorInstalled = @"activator_installed";

static NSString * const kXXRecordConfigRecordVolumeUp = @"record_volume_up";
static NSString * const kXXRecordConfigRecordVolumeDown = @"record_volume_down";

static NSString * const kXXStartUpConfigSwitch = @"startup_run";
static NSString * const kXXStartUpConfigScriptPath = @"startup_script";

@interface XXLocalDataService : YYCache
+ (id)sharedInstance;

@property (nonatomic, assign) kXXKeyPressConfig keyPressConfigHoldVolumeUp; // Cached
@property (nonatomic, assign) kXXKeyPressConfig keyPressConfigHoldVolumeDown; // Cached
@property (nonatomic, assign) kXXKeyPressConfig keyPressConfigPressVolumeUp; // Cached
@property (nonatomic, assign) kXXKeyPressConfig keyPressConfigPressVolumeDown; // Cached
@property (nonatomic, assign) BOOL keyPressConfigActivatorInstalled; // Cached

@property (nonatomic, assign) BOOL recordConfigRecordVolumeUp; // Cached
@property (nonatomic, assign) BOOL recordConfigRecordVolumeDown; // Cached

@property (nonatomic, assign) BOOL startUpConfigSwitch; // Cached
@property (nonatomic, copy) NSString *startUpConfigScriptPath; // Cached

- (BOOL)isSelectedStartUpScriptInPath:(NSString *)path;

@property (nonatomic, strong) NSMutableDictionary *userConfig; // Cached

@property (nonatomic, copy) NSString *rootPath; // Installed
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter; // Static
@property (nonatomic, copy) NSString *selectedScript;
@property (nonatomic, assign) BOOL remoteAccessStatus; // Cached
@property (nonatomic, copy) NSString *remoteAccessURL; // Installed

@property (nonatomic, strong) NSDictionary *deviceInfo; // Cached
@property (nonatomic, strong) NSDate *expirationDate; // Cached

- (BOOL)isSelectedScriptInPath:(NSString *)path;

@property (nonatomic, assign) kXXPasteboardType pasteboardType;
@property (nonatomic, strong) NSMutableArray <NSString *> *pasteboardArr;

@property (nonatomic, assign) kXXScriptListSortMethod sortMethod; // Cached

@property (nonatomic, strong) NSArray *bundles; // Cached

@end
