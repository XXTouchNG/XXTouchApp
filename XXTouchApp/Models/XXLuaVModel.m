//
//  XXLuaVModel.m
//  XXTouchApp
//
//  Created by Zheng on 31/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLuaVModel.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

static NSString * const kXXLuaVModelErrorDomain = @"kXXLuaVModelErrorDomain";

@implementation XXLuaVModel {
    lua_State *L;
}

- (instancetype)init {
    if (self = [super init]) {
        L = luaL_newstate();
        NSAssert(L, @"not enough memory");
        luaL_openlibs(L);
    }
    return self;
}

- (BOOL)checkCode:(int)code error:(NSError **)error {
    if (LUA_OK != code) {
        const char *cErrString = lua_tostring(L, -1);
        NSString *errString = [NSString stringWithUTF8String:cErrString];
        NSDictionary *errDictionary = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Error", nil),
                                         NSLocalizedFailureReasonErrorKey: errString
                                         };
        if (error)
            *error = [NSError errorWithDomain:kXXLuaVModelErrorDomain
                                         code:2
                                     userInfo:errDictionary];
        return NO;
    }
    return YES;
}

- (BOOL)loadFileFromPath:(NSString *)path error:(NSError **)error {
    const char *cString = [path UTF8String];
    int load_stat = luaL_loadfile(L, cString);
    return [self checkCode:load_stat error:error];
}

- (BOOL)pcallWithError:(NSError **)error {
    int load_stat = lua_pcall(L, 0, 0, 0);
    return [self checkCode:load_stat error:error];
}

- (BOOL)loadBufferFromString:(NSString *)string
                       error:(NSError **)error
{
    const char *cString = [string UTF8String];
    int load_stat = luaL_loadbufferx(L, cString, strlen(cString), "", 0);
    return [self checkCode:load_stat error:error];
}

- (BOOL)executeFileAtPath:(NSString *)path {
    __block NSError *err = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(luaWillLoad:)])
    {
        [_delegate luaWillLoad:self];
    }
    BOOL loaded = [self loadFileFromPath:path error:&err];
    if (_delegate && [_delegate respondsToSelector:@selector(luaDidLoad:error:)]) {
        [_delegate luaDidLoad:self error:err];
    }
    if (loaded) {
        if (_delegate && [_delegate respondsToSelector:@selector(luaWillLaunch:)]) {
            [_delegate luaWillLaunch:self];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self pcallWithError:&err];
            dispatch_async_on_main_queue(^{
                if (_delegate && [_delegate respondsToSelector:@selector(luaDidTerminate:error:)]) {
                    [_delegate luaDidTerminate:self error:err];
                }
            });
        });
        if (_delegate && [_delegate respondsToSelector:@selector(luaDidLaunch:)]) {
            [_delegate luaDidLaunch:self];
        }
    }
    return NO;
}

- (void)dealloc {
    if (L) lua_close(L);
}

@end
