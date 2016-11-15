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

typedef enum : NSUInteger {
    kXXEditorFontFamilyCourierNew = 0,
    kXXEditorFontFamilyMenlo = 1,
    kXXEditorFontFamilySourceCodePro = 2,
    kXXEditorFontFamilySourceSansPro = 3,
} kXXEditorFontFamily;

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

static NSString * const kXXLocalConfigHidesMainPath = @"kXXLocalConfigHidesMainPath";

@interface XXLocalDataService : YYCache
+ (id)sharedInstance;

@property (nonatomic, assign) BOOL purchasedProduct; // Cached

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

@property (nonatomic, strong) NSMutableDictionary *localUserConfig; // Cached
@property (nonatomic, strong) NSMutableDictionary *remoteUserConfig; // Cached

@property (nonatomic, copy, readonly) NSString *mainPath; // Installed
@property (nonatomic, copy, readonly) NSString *rootPath; // Installed
@property (nonatomic, strong, readonly) NSDateFormatter *defaultDateFormatter; // Static
@property (nonatomic, strong, readonly) NSDateFormatter *shortDateFormatter; // Static
@property (nonatomic, strong, readonly) NSDateFormatter *miniDateFormatter; // Static
@property (nonatomic, copy) NSString *selectedScript;
@property (nonatomic, assign) BOOL remoteAccessStatus; // Cached
@property (nonatomic, copy, readonly) NSString *remoteAccessURL; // Installed

@property (nonatomic, strong) NSDictionary *deviceInfo; // Cached
@property (nonatomic, strong) NSDate *nowDate; // Cached
@property (nonatomic, strong) NSDate *expirationDate; // Cached

- (BOOL)isSelectedScriptInPath:(NSString *)path;

@property (nonatomic, assign) kXXPasteboardType pasteboardType;
@property (nonatomic, strong) NSMutableArray <NSString *> *pasteboardArr;
@property (nonatomic, assign) kXXScriptListSortMethod sortMethod; // Cached

- (NSString *)randString;

@property (nonatomic, strong) NSArray <NSDictionary *> *bundles; // Cached

@property (nonatomic, assign) kXXEditorFontFamily fontFamily; // Cached
@property (nonatomic, copy, readonly) NSString *fontFamilyName; // Installed
@property (nonatomic, assign) CGFloat fontFamilySize; // Cached
@property (nonatomic, assign) BOOL lineNumbersEnabled; // Cached
@property (nonatomic, assign) NSUInteger tabWidth; // Cached
@property (nonatomic, assign) BOOL softTabsEnabled; // Cached
@property (nonatomic, assign) BOOL autoIndentEnabled; // Cached
@property (nonatomic, assign) BOOL readOnlyEnabled; // Cached
@property (nonatomic, assign) BOOL autoCorrectionEnabled; // Cached
@property (nonatomic, assign) BOOL autoCapitalizationEnabled; // Cached
@property (nonatomic, assign) BOOL regexSearchingEnabled; // Cached
@property (nonatomic, assign) BOOL caseSensitiveEnabled; // Cached
@property (nonatomic, assign) BOOL syntaxHighlightingEnabled; // Cached

- (NSArray <UIFont *> *)fontFamilyArray;
@end
