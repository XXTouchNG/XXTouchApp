//
//  XXLuaVModel.m
//  XXTouchApp
//
//  Created by Zheng on 31/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLuaVModel.h"
#import "XXLocalDataService.h"

void luaL_setPath(lua_State* L, const char *key, const char *path)
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, key); // get field "path" from table at top of stack (-1)
    lua_tostring(L, -1); // grab path string from top of stack
    lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring(L, path); // push the new one
    lua_setfield(L, -2, key); // set the field "path" in table at -2 with value at top of stack
    lua_pop(L, 1); // get rid of package table from top of stack
}

static NSString * const kXXLuaVModelErrorDomain = @"kXXLuaVModelErrorDomain";

@interface XXLuaVModel ()

@end

@implementation XXLuaVModel {
    lua_State *L;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    fakeio(stdin, [[XXLocalDataService sharedInstance] stdoutHandler], [[XXLocalDataService sharedInstance] stderrHandler]);
    L = luaL_newstate();
    NSAssert(L, @"not enough memory");
    luaL_openlibs(L);
}

#pragma mark - check code and error

- (BOOL)checkCode:(int)code error:(NSError **)error {
    if (LUA_OK != code) {
        const char *cErrString = lua_tostring(L, -1);
        NSString *errString = [NSString stringWithUTF8String:cErrString];
        NSDictionary *errDictionary = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Error", nil),
                                         NSLocalizedFailureReasonErrorKey: errString
                                         };
        lua_pop(L, 1);
        if (error)
            *error = [NSError errorWithDomain:kXXLuaVModelErrorDomain
                                         code:code
                                     userInfo:errDictionary];
        return NO;
    }
    return YES;
}

#pragma mark - load from file

- (BOOL)loadFileFromPath:(NSString *)path error:(NSError **)error
{
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    NSString *sPath = [NSString stringWithFormat:@"%@;", [dirPath stringByAppendingPathComponent:@"?.lua"]];
    NSString *cPath = [NSString stringWithFormat:@"%@;", [dirPath stringByAppendingPathComponent:@"?.so"]];
    luaL_setPath(L, "path", sPath.UTF8String);
    luaL_setPath(L, "cpath", cPath.UTF8String);
    
    const char *cString = [path UTF8String];
    int load_stat = luaL_loadfile(L, cString);
    return [self checkCode:load_stat error:error];
}

- (BOOL)loadBufferFromString:(NSString *)string
                       error:(NSError **)error
{
    const char *cString = [string UTF8String];
    int load_stat = luaL_loadbufferx(L, cString, strlen(cString), "", 0);
    return [self checkCode:load_stat error:error];
}

#pragma mark - pcall

- (BOOL)pcallWithError:(NSError **)error {
    int load_stat = lua_pcall(L, 0, 0, 0);
    return [self checkCode:load_stat error:error];
}

#pragma mark - memory

- (void)dealloc {
    if (L) lua_close(L);
    CYLog(@"");
}

@end
