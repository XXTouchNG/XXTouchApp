//
//  XXLocalNetService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

#define CHECK_ERROR(ret) \
if (*error != nil) { \
    return ret; \
}

#define GENERATE_ERROR(c, m, d) (*error = [NSError errorWithDomain:kXXErrorDomain code:[c integerValue] userInfo:@{ NSLocalizedDescriptionKey:m, NSLocalizedFailureReasonErrorKey:d }])

static NSString * const kXXErrorDomain = @"com.xxtouch.error-domain";

@implementation XXLocalNetService
+ (id)sharedInstance {
    static XXLocalNetService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // Init Local Network Configure
        _serverAlive = NO;
    }
    return self;
}

+ (void)cleanGPSCaches {
    
}

+ (void)cleanUICaches {
    
}

+ (void)cleanAllCaches {
    
}

+ (void)respringDevice {
    system("killall -9 SpringBoard");
}

+ (void)restartDevice {
    
}

- (NSDictionary *)sendSynchronousRequest:(NSString *)command
                                withData:(NSData *)data
                                   error:(NSError **)error
{
    NSURL *url = [NSURL URLWithString:[apiUrl stringByAppendingString:command]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (data) {
        [request setHTTPBody:data];
    }
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil
                                                         error:error];
    CHECK_ERROR(nil);
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:received options:0 error:error];
    _serverAlive = YES;
    CHECK_ERROR(nil);
    return result;
}

- (NSDictionary *)sendSynchronousRequest:(NSString *)command
                              withString:(NSString *)string
                                   error:(NSError **)error
{
    NSData *sendData = nil;
    if (string) {
        sendData = [[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [self sendSynchronousRequest:command withData:sendData error:error];
}

- (NSDictionary *)sendSynchronousRequest:(NSString *)command
                          withDictionary:(NSDictionary *)requestParams
                                   error:(NSError **)error
{
    NSData *sendData = nil;
    if (requestParams) {
        sendData = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:error];
        CHECK_ERROR(nil);
    }
    return [self sendSynchronousRequest:command withData:sendData error:error];
}

- (BOOL)sendOneTimeAction:(NSString *)action
                    error:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:action
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    CHECK_ERROR(NO);
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localSetSelectedScript:(NSString *)scriptPath
                         error:(NSError **)error {
    if (scriptPath == nil) {
        return NO;
    }
    NSDictionary *result = [self sendSynchronousRequest:@"select_script_file"
                                         withDictionary:@{ @"filename": scriptPath }
                                                  error:error];
    if (!result) return NO;
    CHECK_ERROR(NO);
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setSelectedScript:scriptPath];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localGetSelectedScriptWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"get_selected_script_file"
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        NSDictionary *data = [result objectForKey:@"data"];
        NSString *filename = [data objectForKey:@"filename"];
        [[XXLocalDataService sharedInstance] setSelectedScript:filename];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localLaunchSelectedScript:(NSString *)scriptPath
                            error:(NSError **)error {
    if (scriptPath == nil) {
        return NO;
    }
    NSDictionary *result = [self sendSynchronousRequest:@"launch_script_file"
                                         withDictionary:@{ @"filename": scriptPath }
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        return YES;
    } else if ([code isEqualToNumber:@2]) {
        NSString *detail = [result objectForKey:@"detail"];
        GENERATE_ERROR(code, message, detail);
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localGetRemoteAccessStatusWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"is_remote_access_opened"
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        NSDictionary *data = [result objectForKey:@"data"];
        NSNumber *opened = [data objectForKey:@"opened"];
        [[XXLocalDataService sharedInstance] setRemoteAccessStatus:[opened boolValue]];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localCleanGPSCachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"clear_gps" error:error];
}

- (BOOL)localCleanUICachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"uicache" error:error];
}

- (BOOL)localCleanAllCachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"clear_all" error:error];
}

- (BOOL)localRespringDeviceWithError:(NSError **)error {
    return [self sendOneTimeAction:@"respring" error:error];
}

- (BOOL)localRestartDeviceWithError:(NSError **)error {
    return [self sendOneTimeAction:@"reboot2" error:error];
}

- (BOOL)localRestartDaemonWithError:(NSError **)error {
    return [self sendOneTimeAction:@"restart" error:error];
}

- (BOOL)localOpenRemoteAccessWithError:(NSError **)error {
    BOOL result = [self sendOneTimeAction:@"open_remote_access" error:error];
    if (result) {
        [[XXLocalDataService sharedInstance] setRemoteAccessStatus:YES];
    }
    return result;
}

- (BOOL)localCloseRemoteAccessWithError:(NSError **)error {
    BOOL result = [self sendOneTimeAction:@"close_remote_access" error:error];
    if (result) {
        [[XXLocalDataService sharedInstance] setRemoteAccessStatus:NO];
    }
    return result;
}

- (BOOL)localGetDeviceAuthInfoWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"device_auth_info"
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        NSDictionary *data = [result objectForKey:@"data"];
        NSNumber *expireDate = [data objectForKey:@"expireDate"];
        [[XXLocalDataService sharedInstance] setExpirationDate:[NSDate dateWithTimeIntervalSince1970:[expireDate unsignedIntegerValue]]];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localGetDeviceInfoWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"deviceinfo"
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        NSDictionary *data = [result objectForKey:@"data"];
        [[XXLocalDataService sharedInstance] setDeviceInfo:[data copy]];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localBindCode:(NSString *)bind
                error:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"bind_code"
                                             withString:bind
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localGetApplicationListWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"applist"
                                         withDictionary:nil
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        NSArray *applist = [result objectForKey:@"data"];
        [[XXLocalDataService sharedInstance] setBundles:applist];
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

- (BOOL)localClearAppData:(NSString *)bid
                    error:(NSError **)error {
    if (bid == nil) {
        return NO;
    }
    NSDictionary *result = [self sendSynchronousRequest:@"clear_app_data"
                                         withDictionary:@{ @"bid": bid }
                                                  error:error];
    if (!result) return NO;
    NSNumber *code = [result objectForKey:@"code"];
    NSString *message = [result objectForKey:@"message"];
    if ([code isEqualToNumber:@0]) {
        return YES;
    } else {
        GENERATE_ERROR(code, message, @"");
    }
    CHECK_ERROR(NO);
    return NO;
}

@end
