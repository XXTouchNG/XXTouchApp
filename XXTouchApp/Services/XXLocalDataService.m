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

static NSString * const kXXTouchStorageDB = @"kXXTouchStorageDB";

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

- (void)setSelectedScript:(NSString *)selectedScript {
    _selectedScript = selectedScript;
    if (selectedScript) {
        CYLog(@"%@", selectedScript);
    }
}

- (BOOL)isSelectedScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [_selectedScript hasPrefix:path];
}

- (NSString *)remoteAccessURL {
    NSString *wifiAddress = [[UIDevice currentDevice] ipAddressWIFI];
    if (wifiAddress == nil) {
        return nil;
    }
    return [NSString stringWithFormat:remoteAccessUrl, wifiAddress];
}

- (NSDictionary *)deviceInfo {
    return (NSDictionary *)[self objectForKey:@"deviceInfo"];
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo {
    [self setObject:deviceInfo forKey:@"deviceInfo"];
}

- (NSDate *)expirationDate {
    return (NSDate *)[self objectForKey:@"expirationDate"];
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    [self setObject:expirationDate forKey:@"expirationDate"];
}

- (NSArray *)bundles {
    NSArray *bundles = (NSArray *)[self objectForKey:@"bundles"];
    if (!bundles) {
        return @[];
    }
    return bundles;
}

- (void)setBundles:(NSArray *)bundles {
    [self setObject:bundles forKey:@"bundles"];
}

@end
