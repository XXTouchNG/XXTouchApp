//
//  XXLocalDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef XXLocalDefines_h
#define XXLocalDefines_h

static NSDictionary *extendApisDict = nil;
static BOOL needRespring = YES;
static BOOL jailbroken = NO;
static BOOL installed = NO;
static NSString * const tmpLockedItemPath = @"/private/var/tmp/1ferver_need_respring";

static inline BOOL isJailbroken() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef DEBUG
        jailbroken = [[UIDevice currentDevice] isJailbroken];
#else
        jailbroken = NO;
#endif
    });
    return jailbroken;
}

static inline BOOL daemonInstalled() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef DEBUG
        installed = isJailbroken() ? [[NSFileManager defaultManager] isReadableFileAtPath:MAIN_PATH] : NO;
#else
        installed = NO;
#endif
    });
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

static inline NSString *apiUrl() {
    loadExtendApis();
    return extendApisDict[@"localApi"];
}

static inline NSString *remoteAccessUrl() {
    loadExtendApis();
    return extendApisDict[@"remoteApi"];
}

static inline NSString *remoteUrl() {
    loadExtendApis();
    return extendApisDict[@"authApi"];
}

typedef enum : NSUInteger {
    kXXLocalCommandMethodGET  = 0,
    kXXLocalCommandMethodPOST = 1,
} XXLocalCommandMethod;

#endif /* XXLocalDefines_h */
