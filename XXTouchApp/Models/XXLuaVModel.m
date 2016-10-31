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
    }
    return self;
}

- (BOOL)loadBufferFromString:(NSString *)string
                       error:(NSError **)error
{
    const char *cString = [string UTF8String];
    int load_stat = luaL_loadbufferx(L, cString, strlen(cString), "", 0);
    if (LUA_OK != load_stat) {
        const char *cErrString = lua_tostring(L, -1);
        NSString *errString = [NSString stringWithUTF8String:cErrString];
        if (errString.length >= 11)
            errString = [errString substringFromIndex:11];
        NSDictionary *errDictionary = @{ NSLocalizedDescriptionKey: errString };
        if (error)
            *error = [NSError errorWithDomain:kXXLuaVModelErrorDomain
                                         code:load_stat
                                     userInfo:errDictionary];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    if (L) lua_close(L);
}

@end
