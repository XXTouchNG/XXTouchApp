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
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ALAssetsLibrary+SingleInstance.h"
#import "PHPhotoLibrary+CustomPhotoCollection.h"

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
        if ([[NSFileManager defaultManager] isReadableFileAtPath:FEVER_PATH]) {
            _rootPath = FEVER_PATH;
        } else {
            _rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }
    }
    return _rootPath;
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
                                                    [imageViewer.view makeToast:NSLocalizedString(@"Image saved to the album", nil)];
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
                [imageViewer.view makeToast:NSLocalizedString(@"Failed to request photo library access", nil)];
            } else if (statusResult == FYPhotoLibraryPermissionStatusGranted) {
                [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                                       toAlbum:@"XXTouch"
                                                    completion:^(BOOL success) {
                                                        if (success) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:NSLocalizedString(@"Image saved to the album", nil)];
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

#pragma mark - Code Snippet

- (NSMutableArray <XXCodeBlockModel *> *)codeBlockInternalFunctions {
    NSMutableArray <XXCodeBlockModel *> * obj = (NSMutableArray <XXCodeBlockModel *> *)[self objectForKey:@"codeBlockInternalFunctions"];
    if (!obj) {
        NSMutableArray <XXCodeBlockModel *> *codeBlocks = [[NSMutableArray alloc] initWithArray:
  @[
    [XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(@pos@)" offset:10],
    [XXCodeBlockModel modelWithTitle:@"touch.on(x, y):move(x1, y1)" code:@"touch.on(@pos@):move(@pos@)" offset:9],
    [XXCodeBlockModel modelWithTitle:@"screen.ocr_text(left, top, right, bottom)" code:@"screen.ocr_text(@pos@, @pos@)" offset:16],
    [XXCodeBlockModel modelWithTitle:@"screen.is_colors(colors, similarity)" code:@"screen.is_colors(@poscolors@, @slider@)" offset:17],
    [XXCodeBlockModel modelWithTitle:@"screen.find_color(colors, similarity)" code:@"screen.find_color(@poscolors@, @slider@)" offset:18],
    [XXCodeBlockModel modelWithTitle:@"key.press(key)" code:@"key.press(@key@)" offset:10],
    [XXCodeBlockModel modelWithTitle:@"app.run(bid)" code:@"app.run(\"@bid@\")" offset:8],
    [XXCodeBlockModel modelWithTitle:@"app.close(bid)" code:@"app.close(\"@bid@\")" offset:10],
    [XXCodeBlockModel modelWithTitle:@"app.quit(bid)" code:@"app.quit(\"@bid@\")" offset:9],
    [XXCodeBlockModel modelWithTitle:@"app.bundle_path(bid)" code:@"app.bundle_path(\"@bid@\")" offset:16],
    [XXCodeBlockModel modelWithTitle:@"app.data_path(bid)" code:@"app.data_path(\"@bid@\")" offset:14],
    [XXCodeBlockModel modelWithTitle:@"app.is_running(bid)" code:@"app.is_running(\"@bid@\")" offset:15],
    [XXCodeBlockModel modelWithTitle:@"app.is_front(bid)" code:@"app.is_front(\"@bid@\")" offset:13],
    [XXCodeBlockModel modelWithTitle:@"app.uninstall(bid)" code:@"app.uninstall(\"@bid@\")" offset:14],
    [XXCodeBlockModel modelWithTitle:@"clear.keychain(bid)" code:@"clear.keychain(\"@bid@\")" offset:15],
    [XXCodeBlockModel modelWithTitle:@"clear.app_data(bid)" code:@"clear.app_data(\"@bid@\")" offset:15],
    ]];
        obj = codeBlocks;
        [self setObject:codeBlocks forKey:@"codeBlockInternalFunctions"];
    }
    return obj;
}

- (void)setCodeBlockInternalFunctions:(NSArray<XXCodeBlockModel *> *)codeBlockInternalFunctions {
    [self setObject:codeBlockInternalFunctions forKey:@"codeBlockInternalFunctions"];
}

- (NSMutableArray <XXCodeBlockModel *> *)codeBlockUserDefinedFunctions {
    NSMutableArray <XXCodeBlockModel *> * obj = (NSMutableArray <XXCodeBlockModel *> *)[self objectForKey:@"codeBlockUserDefinedFunctions"];
    if (!obj)
        obj = [[NSMutableArray alloc] init];
    return obj;
}

- (void)setCodeBlockUserDefinedFunctions:(NSMutableArray<XXCodeBlockModel *> *)codeBlockUserDefinedFunctions {
    [self setObject:codeBlockUserDefinedFunctions forKey:@"codeBlockUserDefinedFunctions"];
}

@end
