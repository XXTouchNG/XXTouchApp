//
//  XXLocalDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef XXLocalDefines_h
#define XXLocalDefines_h

static BOOL _needRespring = YES;
static BOOL _jailbroken = NO;
static BOOL _installed = NO;
static NSDictionary *_extendApisDict = nil;

static NSDictionary *extendDict() {
    if (!_extendApisDict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AppDefines" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        _extendApisDict = dict;
    }
    return _extendApisDict;
}

static inline BOOL needsRespring() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _needRespring = [[NSFileManager defaultManager] fileExistsAtPath:extendDict()[@"RESPRING_CHECK_PATH"]];
    });
    return _needRespring;
}

static BOOL isJailbroken() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jailbroken = NO;
        NSArray *paths = @[ @"/Applications/Cydia.app" ];
        for (NSString *path in paths) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                _jailbroken = YES;
                break;
            }
        }
        FILE *bash = fopen("/bin/bash", "r");
        if (bash != NULL) {
            fclose(bash);
            _jailbroken = YES;
        }
    });
//#ifdef DEBUG
//    return YES;
//#endif
    return _jailbroken;
}

static inline BOOL daemonInstalled() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (isJailbroken()) {
            _installed = [[NSFileManager defaultManager] fileExistsAtPath:extendDict()[@"XXTOUCH_APP_PATH"]];
        } else {
            _installed = NO;
        }
    });
//#ifdef DEBUG
//    return YES;
//#endif
    return _installed;
}

#endif /* XXLocalDefines_h */
