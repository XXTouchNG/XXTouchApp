//
//  XXLocalDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef XXLocalDefines_h
#define XXLocalDefines_h

static BOOL needRespring = YES;
static BOOL jailbroken = NO;
static BOOL installed = NO;
static NSDictionary *extendApisDict = nil;
static NSString * const tmpLockedItemPath = @"/private/var/tmp/1ferver_need_respring";

static inline BOOL isJailbroken() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jailbroken = NO;
        NSArray *paths = @[ @"/Applications/Cydia.app" ];
        for (NSString *path in paths) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                jailbroken = YES;
                break;
            }
        }
        FILE *bash = fopen("/bin/bash", "r");
        if (bash != NULL) {
            fclose(bash);
            jailbroken = YES;
        }
    });
#ifdef DEBUG
    return YES;
#endif
    return jailbroken;
}

static inline BOOL daemonInstalled() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (isJailbroken()) {
            installed = [[NSFileManager defaultManager] fileExistsAtPath:XXTOUCH_APP_PATH];
        } else {
            installed = NO;
        }
    });
#ifdef DEBUG
    return YES;
#endif
    return installed;
}

static inline BOOL needsRespring() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needRespring = [[NSFileManager defaultManager] fileExistsAtPath:tmpLockedItemPath];
    });
    return needRespring;
}

static inline void loadExtendApis() {
    if (!extendApisDict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"extendApis" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        extendApisDict = dict;
    }
}

static inline NSDictionary *extendDict() {
    loadExtendApis();
    return extendApisDict;
}
#endif /* XXLocalDefines_h */
