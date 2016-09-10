//
//  XXLocalDataService.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kXXPasteboardTypeCopy,
    kXXPasteboardTypeCut,
} kXXPasteboardType;

typedef enum : NSUInteger {
    kXXScriptListSortByNameAsc,
    kXXScriptListSortByModificationDesc,
} kXXScriptListSortMethod;

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

@interface XXLocalDataService : NSObject
+ (id)sharedInstance;

@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, copy) NSString *selectedScript;
@property (nonatomic, assign) BOOL remoteAccessStatus;
@property (nonatomic, copy) NSString *remoteAccessURL;

@property (nonatomic, strong) NSDictionary *deviceInfo;
@property (nonatomic, strong) NSDate *expirationDate;

- (BOOL)isSelectedScriptInPath:(NSString *)path;

@property (nonatomic, assign) kXXPasteboardType pasteboardType;
@property (nonatomic, strong) NSMutableArray <NSString *> *pasteboardArr;

@property (nonatomic, assign) kXXScriptListSortMethod sortMethod;

@end
