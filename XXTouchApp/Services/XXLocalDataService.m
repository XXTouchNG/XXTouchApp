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
@property (nonatomic, strong) NSArray <NSString *> *randStrings;

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

- (NSDateFormatter *)shortDateFormatter {
    if (!_shortDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d/M/yy, h:mm a"];
        _shortDateFormatter = dateFormatter;
    }
    return _shortDateFormatter;
}

- (NSDateFormatter *)miniDateFormatter {
    if (!_miniDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d/M/yy"];
        _miniDateFormatter = dateFormatter;
    }
    return _miniDateFormatter;
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
    return (NSDictionary *)[self objectForKey:[NSString stringWithFormat:@"deviceInfo-%@", VERSION_BUILD]];
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo {
    [self setObject:deviceInfo forKey:[NSString stringWithFormat:@"deviceInfo-%@", VERSION_BUILD]];
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
    NSMutableArray <XXCodeBlockModel *> * obj = (NSMutableArray <XXCodeBlockModel *> *)[self objectForKey:[NSString stringWithFormat:@"codeBlockInternalFunctions-%@", VERSION_BUILD]];
    if (!obj) {
        obj = [[NSMutableArray alloc] initWithArray:
@[
[XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(@pos@@cur@)"],
[XXCodeBlockModel modelWithTitle:@"touch.on(x, y):move(x1, y1)" code:@"touch.on(@pos@@cur@):move(@pos@)"],
[XXCodeBlockModel modelWithTitle:@"screen.ocr_text(left, top, right, bottom)" code:@"screen.ocr_text(@pos@@cur@, @pos@)"],
[XXCodeBlockModel modelWithTitle:@"screen.is_colors(colors, similarity)" code:@"screen.is_colors(@poscolors@@cur@, @slider@)"],
[XXCodeBlockModel modelWithTitle:@"screen.find_color(colors, similarity)" code:@"screen.find_color(@poscolors@@cur@, @slider@)"],
[XXCodeBlockModel modelWithTitle:@"key.press(key)" code:@"key.press(\"@key@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"gps.fake(bid, latitude, longitude)" code:@"gps.fake(\"@bid@@cur@\", @loc@)"],
[XXCodeBlockModel modelWithTitle:@"gps.clear([bid])" code:@"gps.fake(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.run(bid)" code:@"app.run(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.close(bid)" code:@"app.close(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.quit(bid)" code:@"app.quit(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.bundle_path(bid)" code:@"app.bundle_path(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.data_path(bid)" code:@"app.data_path(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.is_running(bid)" code:@"app.is_running(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.is_front(bid)" code:@"app.is_front(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"app.uninstall(bid)" code:@"app.uninstall(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"clear.keychain(bid)" code:@"clear.keychain(\"@bid@@cur@\")"],
[XXCodeBlockModel modelWithTitle:@"clear.app_data(bid)" code:@"clear.app_data(\"@bid@@cur@\")"],
]];
        [self setObject:obj forKey:[NSString stringWithFormat:@"codeBlockInternalFunctions-%@", VERSION_BUILD]];
    }
    return obj;
}

- (void)setCodeBlockInternalFunctions:(NSArray<XXCodeBlockModel *> *)codeBlockInternalFunctions {
    [self setObject:codeBlockInternalFunctions forKey:[NSString stringWithFormat:@"codeBlockInternalFunctions-%@", VERSION_BUILD]];
}

- (NSMutableArray <XXCodeBlockModel *> *)codeBlockUserDefinedFunctions {
    NSMutableArray <XXCodeBlockModel *> * obj = (NSMutableArray <XXCodeBlockModel *> *)[self objectForKey:@"codeBlockUserDefinedFunctions"];
    if (!obj) {
        obj = [[NSMutableArray alloc] initWithArray:
@[
[XXCodeBlockModel modelWithTitle:@"print()" code:@"print(@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"print.out()" code:@"print.out(@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"sys.toast(\"\")" code:@"sys.toast(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"sys.alert(\"\", 0)" code:@"sys.alert(\"@cur@\", 0)\n"],
[XXCodeBlockModel modelWithTitle:@"if ... then ... end" code:@"if () then\n\nend\n"],
[XXCodeBlockModel modelWithTitle:@"for i = 1, 10, 1 do ... end" code:@"for i = 1, 10, 1 do\n\t@cur@\nend\n"],
[XXCodeBlockModel modelWithTitle:@"while (true) do .. end" code:@"while (true) do\n\t@cur@\nend\n"],
[XXCodeBlockModel modelWithTitle:@"repeat ... until (false)" code:@"repeat\n\t@cur@\nuntil (false)\n"],
[XXCodeBlockModel modelWithTitle:@"sys.msleep(1000)" code:@"sys.msleep(1000@cur@)\n"],
[XXCodeBlockModel modelWithTitle:@"touch.tap(x, y)" code:@"touch.tap(x@cur@, y)\n"],
[XXCodeBlockModel modelWithTitle:@"app.input_text(\"\")" code:@"app.input_text(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"accelerometer.shake()" code:@"accelerometer.shake()\n"],
[XXCodeBlockModel modelWithTitle:@"r = sys.input_box(\"\")" code:@"r = sys.input_box(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"pasteboard.write(\"\")" code:@"pasteboard.write(\"@cur@\")\n"],
[XXCodeBlockModel modelWithTitle:@"r = pasteboard.read()" code:@"r = pasteboard.read()\n"],
[XXCodeBlockModel modelWithTitle:@"os.execute(\"\")" code:@"os.execute(\"@cur@\")\n"],
]];
        [self setObject:obj forKey:@"codeBlockUserDefinedFunctions"];
    }
    
    return obj;
}

- (void)setCodeBlockUserDefinedFunctions:(NSMutableArray<XXCodeBlockModel *> *)codeBlockUserDefinedFunctions {
    [self setObject:codeBlockUserDefinedFunctions forKey:@"codeBlockUserDefinedFunctions"];
}

- (NSUInteger)selectedCodeBlockSegmentIndex {
    return [(NSNumber *)[self objectForKey:@"selectedCodeBlockSegmentIndex"] unsignedIntegerValue];
}

- (void)setSelectedCodeBlockSegmentIndex:(NSUInteger)selectedCodeBlockSegmentIndex {
    [self setObject:[NSNumber numberWithUnsignedInteger:selectedCodeBlockSegmentIndex] forKey:@"selectedCodeBlockSegmentIndex"];
}

- (NSArray <NSString *> *)randStrings {
    if (!_randStrings) {
        _randStrings =
@[
@"6ZW/6aOO56C05rWq5Lya5pyJ5pe277yM6Zeu5oiR5ruL56OB5LiN5ruL56OB44CC",
@"5LiA6Lqr5Y675Zu95YWt5Y2D6YeM77yM5oiR5bCx5piO56Gu5ZGK6K+J5L2g44CC",
@"5rit5bed5pac6Ziz54Wn5aKf6JC977yM5ZOq5Liq5Zu95a625rKh5Y676L+H44CC",
@"55m+5aO25LiU6K+V5byA5oCA5oqx77yM54af5oKJ6KW/5pa56YKj5LiA5aWX44CC",
@"5Zyo5aSp5oS/5L2c5q+U57+86bif77yM5Lq655Sf57uP6aqM6L+Y5aSq5bCR44CC",
@"5Y2D6YeR5pWj5bC96L+Y5aSN5p2l77yM5pWZ5L2g6Ze35aOw5Y+R5aSn6LSi44CC",
@"6ZW/5L2/6Iux6ZuE5rOq5ruh6KWf77yM5L2g5Lus6L+Y5piv5aSq5bm06L2744CC",
@"57+g5b2x57qi6Zye5pig5pyd5pel77yM5pyJ5pe255Sa6Iez5b6I5bm856ia44CC",
@"6I6r56yR5Yac5a626IWK6YWS5re377yM5byE5Ye65LiA5Liq5aSn5paw6Ze744CC",
@"5raI5oGv5LiN6YCa5L2V6K6h5piv77yM576O5Zu95pyJ5Liq5Y2O6I6x5aOr44CC",
@"6Zuq5raI6Zeo5aSW5Y2D5bGx57u/77yM5LiN55+l6auY5Yiw5ZOq6YeM5Y6744CC",
@"5q2k5aSc5pyJ5oOF6LCB5LiN5p6B77yM5L2g5Lus6L+Y6KaB5aSa5a2m5Lmg44CC",
];
    }
    return _randStrings;
}

- (NSString *)randString {
    NSUInteger rand = arc4random() % self.randStrings.count;
    return self.randStrings[rand];
}

@end
