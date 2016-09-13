//
//  XXLocalDataService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDefines.h"
#import "XXLocalDataService.h"
#import "JTSImageViewController.h"
#import "FYPhotoLibrary.h"

static NSString * const kXXTouchStorageDB = @"kXXTouchStorageDB";

@interface XXLocalDataService () <
    JTSImageViewControllerInteractionsDelegate
>

@end

@implementation XXLocalDataService

+ (id)sharedInstance {
    static XXLocalDataService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithName:kXXTouchStorageDB];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // Init Local Data Configure
        
    }
    return self;
}

- (NSString *)rootPath {
    if (!_rootPath) {
        _rootPath = [[UIApplication sharedApplication] documentsPath];
    }
    return _rootPath;
}

- (NSString *)libraryPath {
    if (!_libraryPath) {
        _libraryPath = [[UIApplication sharedApplication] libraryPath];
    }
    return _libraryPath;
}

- (NSDateFormatter *)defaultDateFormatter {
    if (!_defaultDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _defaultDateFormatter = dateFormatter;
    }
    return _defaultDateFormatter;
}

- (NSMutableArray <NSString *> *)pasteboardArr {
    if (!_pasteboardArr) {
        _pasteboardArr = [[NSMutableArray alloc] init];
    }
    return _pasteboardArr;
}

- (NSString *)selectedScript {
    return (NSString *)[self objectForKey:@"selectedScript"];
}

- (void)setSelectedScript:(NSString *)selectedScript {
    [self setObject:selectedScript forKey:@"selectedScript"];
}

- (NSString *)startUpConfigScriptPath {
    return (NSString *)[self objectForKey:@"startUpConfigScriptPath"];
}

- (void)setStartUpConfigScriptPath:(NSString *)startUpConfigScriptPath {
    [self setObject:startUpConfigScriptPath forKey:@"startUpConfigScriptPath"];
}

- (BOOL)isSelectedScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [self.selectedScript hasPrefix:path];
}

- (BOOL)isSelectedStartUpScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [self.startUpConfigScriptPath hasPrefix:path];
}

- (NSString *)remoteAccessURL {
    NSString *wifiAddress = [[UIDevice currentDevice] ipAddressWIFI];
    if (wifiAddress == nil) {
        return nil;
    }
    return [NSString stringWithFormat:remoteAccessUrl, wifiAddress];
}

- (BOOL)remoteAccessStatus {
    return [(NSNumber *)[self objectForKey:@"remoteAccessStatus"] boolValue];
}

- (void)setRemoteAccessStatus:(BOOL)remoteAccessStatus {
    [self setObject:[NSNumber numberWithBool:remoteAccessStatus] forKey:@"remoteAccessStatus"];
}

- (NSDictionary *)deviceInfo {
    return (NSDictionary *)[self objectForKey:@"deviceInfo"];
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo {
    [self setObject:deviceInfo forKey:@"deviceInfo"];
}

- (NSDictionary *)userConfig {
    return (NSDictionary *)[self objectForKey:@"userConfig"];
}

- (void)setUserConfig:(NSDictionary *)userConfig {
    [self setObject:userConfig forKey:@"userConfig"];
}

- (NSDate *)expirationDate {
    return (NSDate *)[self objectForKey:@"expirationDate"];
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    [self setObject:expirationDate forKey:@"expirationDate"];
}

- (NSArray *)bundles {
    NSArray *bundles = (NSArray *)[self objectForKey:@"bundles"];
    if (!bundles)
        return @[];
    return bundles;
}

- (void)setBundles:(NSArray *)bundles {
    [self setObject:bundles forKey:@"bundles"];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    imageViewer.view.userInteractionEnabled = NO;
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // 7.x
        [[ALAssetsLibrary sharedLibrary] saveImage:imageViewer.image
                                           toAlbum:@"XXTouch"
                                        completion:^(NSURL *assetURL, NSError *error) {
                                            if (error == nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:XXLString(@"Image saved to the album.")];
                                                });
                                            }
                                        } failure:^(NSError *error) {
                                            if (error != nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:[error localizedDescription]];
                                                });
                                            }
                                        }];
    } else {
        // 8.0+
        [[FYPhotoLibrary sharedInstance] requestLibraryAccessHandler:^(FYPhotoLibraryPermissionStatus statusResult) {
            if (statusResult == FYPhotoLibraryPermissionStatusDenied) {
                imageViewer.view.userInteractionEnabled = YES;
                [imageViewer.view hideToastActivity];
                [imageViewer.view makeToast:XXLString(@"Failed to request photo library access.")];
            } else if (statusResult == FYPhotoLibraryPermissionStatusGranted) {
                [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                                       toAlbum:@"XXTouch"
                                                    completion:^(BOOL success) {
                                                        if (success) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:XXLString(@"Image saved to the album.")];
                                                            });
                                                        }
                                                    } failure:^(NSError * _Nullable error) {
                                                        if (error != nil) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:[error localizedDescription]];
                                                            });
                                                        }
                                                    }];
            }
        }];
    }
}

- (kXXScriptListSortMethod)sortMethod {
    return [(NSNumber *)[self objectForKey:@"sortMethod"] integerValue];
}

- (void)setSortMethod:(kXXScriptListSortMethod)sortMethod {
    [self setObject:[NSNumber numberWithInteger:sortMethod] forKey:@"sortMethod"];
}

- (BOOL)startUpConfigSwitch {
    return [(NSNumber *)[self objectForKey:@"startUpConfigSwitch"] boolValue];
}

- (void)setStartUpConfigSwitch:(BOOL)startUpConfigSwitch {
    [self setObject:[NSNumber numberWithBool:startUpConfigSwitch] forKey:@"startUpConfigSwitch"];
}

- (BOOL)keyPressConfigActivatorInstalled {
    return [(NSNumber *)[self objectForKey:@"keyPressConfigActivatorInstalled"] boolValue];
}

- (void)setKeyPressConfigActivatorInstalled:(BOOL)keyPressConfigActivatorInstalled {
    [self setObject:[NSNumber numberWithBool:keyPressConfigActivatorInstalled] forKey:@"keyPressConfigActivatorInstalled"];
}

- (BOOL)recordConfigRecordVolumeUp {
    return [(NSNumber *)[self objectForKey:@"recordConfigRecordVolumeUp"] boolValue];
}

- (void)setRecordConfigRecordVolumeUp:(BOOL)recordConfigRecordVolumeUp {
    [self setObject:[NSNumber numberWithBool:recordConfigRecordVolumeUp] forKey:@"recordConfigRecordVolumeUp"];
}

- (BOOL)recordConfigRecordVolumeDown {
    return [(NSNumber *)[self objectForKey:@"recordConfigRecordVolumeDown"] boolValue];
}

- (void)setRecordConfigRecordVolumeDown:(BOOL)recordConfigRecordVolumeDown {
    [self setObject:[NSNumber numberWithBool:recordConfigRecordVolumeDown] forKey:@"recordConfigRecordVolumeDown"];
}

- (kXXKeyPressConfig)keyPressConfigHoldVolumeUp {
    return [(NSNumber *)[self objectForKey:@"keyPressConfigHoldVolumeUp"] integerValue];
}

- (void)setKeyPressConfigHoldVolumeUp:(kXXKeyPressConfig)keyPressConfigHoldVolumeUp {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigHoldVolumeUp] forKey:@"keyPressConfigHoldVolumeUp"];
}

- (kXXKeyPressConfig)keyPressConfigHoldVolumeDown {
    return [(NSNumber *)[self objectForKey:@"keyPressConfigHoldVolumeDown"] integerValue];
}

- (void)setKeyPressConfigHoldVolumeDown:(kXXKeyPressConfig)keyPressConfigHoldVolumeDown {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigHoldVolumeDown] forKey:@"keyPressConfigHoldVolumeDown"];
}

- (kXXKeyPressConfig)keyPressConfigPressVolumeUp {
    return [(NSNumber *)[self objectForKey:@"keyPressConfigPressVolumeUp"] integerValue];
}

- (void)setKeyPressConfigPressVolumeUp:(kXXKeyPressConfig)keyPressConfigPressVolumeUp {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigPressVolumeUp] forKey:@"keyPressConfigPressVolumeUp"];
}

- (kXXKeyPressConfig)keyPressConfigPressVolumeDown {
    return [(NSNumber *)[self objectForKey:@"keyPressConfigPressVolumeDown"] integerValue];
}

- (void)setKeyPressConfigPressVolumeDown:(kXXKeyPressConfig)keyPressConfigPressVolumeDown {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigPressVolumeDown] forKey:@"keyPressConfigPressVolumeDown"];
}

@end
