//
//  XXLocalNetService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

#define CHECK_ERROR(ret) if (*error != nil) return ret;

#define GENERATE_ERROR(d) (*error = [NSError errorWithDomain:kXXErrorDomain code:[result[@"code"] integerValue] userInfo:@{ NSLocalizedDescriptionKey:result[@"message"], NSLocalizedFailureReasonErrorKey:d }])

static NSString * const kXXErrorDomain = @"com.xxtouch.error-domain";

@implementation XXLocalNetService

+ (NSDictionary *)sendSynchronousRequest:(NSString *)command
                                withData:(NSData *)data
                                   error:(NSError **)error
{
    NSURL *url = [NSURL URLWithString:[apiUrl stringByAppendingString:command]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (data) [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error]; CHECK_ERROR(nil);
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:received options:0 error:error]; CHECK_ERROR(nil);
    return result;
}

+ (NSDictionary *)sendSynchronousRequest:(NSString *)command
                              withString:(NSString *)string
                                   error:(NSError **)error
{
    NSData *sendData = [[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]; CHECK_ERROR(nil);
    return [self sendSynchronousRequest:command withData:sendData error:error];
}

+ (NSDictionary *)sendSynchronousRequest:(NSString *)command
                          withDictionary:(NSDictionary *)requestParams
                                   error:(NSError **)error
{
    NSData *sendData = nil;
    if (requestParams) sendData = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:error]; CHECK_ERROR(nil);
    return [self sendSynchronousRequest:command withData:sendData error:error];
}

+ (NSDictionary *)sendSynchronousRequest:(NSString *)command
                        withIntegerValue:(NSInteger)value
                                   error:(NSError **)error {
    NSString *sendString = [NSString stringWithFormat:@"%lu", value]; CHECK_ERROR(nil);
    return [self sendSynchronousRequest:command withString:sendString error:error];
}

+ (BOOL)sendOneTimeAction:(NSString *)action
                    error:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:action withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0])
        return YES;
    else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localSetSelectedScript:(NSString *)scriptPath
                         error:(NSError **)error {
    NSAssert(scriptPath != nil, @"scriptPath cannot be nil");
    NSDictionary *result = [self sendSynchronousRequest:@"select_script_file" withDictionary:@{ @"filename": scriptPath } error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setSelectedScript:scriptPath];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localGetSelectedScriptWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"get_selected_script_file" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setSelectedScript:result[@"data"][@"filename"]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localLaunchSelectedScript:(NSString *)scriptPath
                            error:(NSError **)error {
    NSAssert(scriptPath != nil, @"scriptPath cannot be nil");
    NSDictionary *result = [self sendSynchronousRequest:@"launch_script_file" withDictionary:@{ @"filename": scriptPath } error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        return YES;
    } else if ([result[@"code"] isEqualToNumber:@2]) {
        GENERATE_ERROR(result[@"detail"]);
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localGetRemoteAccessStatusWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"is_remote_access_opened" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setRemoteAccessStatus:[result[@"data"][@"opened"] boolValue]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localCleanGPSCachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"clear_gps" error:error];
}

+ (BOOL)localCleanUICachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"uicache" error:error];
}

+ (BOOL)localCleanAllCachesWithError:(NSError **)error {
    return [self sendOneTimeAction:@"clear_all" error:error];
}

+ (BOOL)localRespringDeviceWithError:(NSError **)error {
    return [self sendOneTimeAction:@"respring" error:error];
}

+ (BOOL)localRestartDeviceWithError:(NSError **)error {
    return [self sendOneTimeAction:@"reboot2" error:error];
}

+ (BOOL)localRestartDaemonWithError:(NSError **)error {
    return [self sendOneTimeAction:@"restart" error:error];
}

+ (BOOL)localOpenRemoteAccessWithError:(NSError **)error {
    [self sendOneTimeAction:@"open_remote_access" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRemoteAccessStatus:YES];
    return YES;
}

+ (BOOL)localCloseRemoteAccessWithError:(NSError **)error {
    [self sendOneTimeAction:@"close_remote_access" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRemoteAccessStatus:NO];
    return YES;
}

+ (BOOL)localGetDeviceAuthInfoWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"device_auth_info" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setExpirationDate:[NSDate dateWithTimeIntervalSince1970:[result[@"data"][@"expireDate"] unsignedIntegerValue]]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localGetDeviceInfoWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"deviceinfo" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setDeviceInfo:[result[@"data"] copy]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localBindCode:(NSString *)bind
                error:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"bind_code" withString:bind error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0])
        return YES;
    else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localGetApplicationListWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"applist" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        [[XXLocalDataService sharedInstance] setBundles:result[@"data"]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localClearAppData:(NSString *)bid
                    error:(NSError **)error {
    NSAssert(bid != nil, @"bid cannot be nil");
    NSDictionary *result = [self sendSynchronousRequest:@"clear_app_data" withDictionary:@{ @"bid": bid } error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localGetVolumeActionConfWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"get_volume_action_conf" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        NSDictionary *data = result[@"data"];
        XXLocalDataService *sharedDataService = [XXLocalDataService sharedInstance];
        [sharedDataService setKeyPressConfigHoldVolumeUp:[(NSNumber *)[data objectForKey:kXXKeyPressConfigHoldVolumeUp] integerValue]];
        [sharedDataService setKeyPressConfigHoldVolumeDown:[(NSNumber *)[data objectForKey:kXXKeyPressConfigHoldVolumeDown] integerValue]];
        [sharedDataService setKeyPressConfigPressVolumeUp:[(NSNumber *)[data objectForKey:kXXKeyPressConfigPressVolumeUp] integerValue]];
        [sharedDataService setKeyPressConfigPressVolumeDown:[(NSNumber *)[data objectForKey:kXXKeyPressConfigPressVolumeDown] integerValue]];
        [sharedDataService setKeyPressConfigActivatorInstalled:[(NSNumber *)[data objectForKey:kXXKeyPressConfigActivatorInstalled] boolValue]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localSetHoldVolumeUpAction:(NSUInteger)option error:(NSError **)error {
    BOOL result = [self sendSynchronousRequest:@"set_hold_volume_up_action" withIntegerValue:option error:error];
    CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setKeyPressConfigHoldVolumeUp:option];
    return result;
}

+ (BOOL)localSetHoldVolumeDownAction:(NSUInteger)option error:(NSError **)error {
    [self sendSynchronousRequest:@"set_hold_volume_down_action" withIntegerValue:option error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setKeyPressConfigHoldVolumeDown:option];
    return YES;
}

+ (BOOL)localSetPressVolumeUpAction:(NSUInteger)option error:(NSError **)error {
    [self sendSynchronousRequest:@"set_click_volume_up_action" withIntegerValue:option error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setKeyPressConfigPressVolumeUp:option];
    return YES;
}

+ (BOOL)localSetPressVolumeDownAction:(NSUInteger)option error:(NSError **)error {
    [self sendSynchronousRequest:@"set_click_volume_down_action" withIntegerValue:option error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setKeyPressConfigPressVolumeDown:option];
    return YES;
}

+ (BOOL)localGetRecordConfWithError:(NSError **)error {
    NSDictionary *result = [self sendSynchronousRequest:@"get_record_conf" withDictionary:nil error:error]; CHECK_ERROR(NO);
    if ([result[@"code"] isEqualToNumber:@0]) {
        NSDictionary *data = result[@"data"];
        XXLocalDataService *sharedDataService = [XXLocalDataService sharedInstance];
        [sharedDataService setRecordConfigRecordVolumeUp:[(NSNumber *)[data objectForKey:kXXRecordConfigRecordVolumeUp] boolValue]];
        [sharedDataService setRecordConfigRecordVolumeDown:[(NSNumber *)[data objectForKey:kXXRecordConfigRecordVolumeDown] boolValue]];
        return YES;
    } else
        GENERATE_ERROR(@"");
    return NO;
}

+ (BOOL)localSetRecordVolumeUpOnWithError:(NSError **)error {
    [self sendOneTimeAction:@"set_record_volume_up_on" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRecordConfigRecordVolumeUp:YES];
    return YES;
}

+ (BOOL)localSetRecordVolumeUpOffWithError:(NSError **)error {
    [self sendOneTimeAction:@"set_record_volume_up_off" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRecordConfigRecordVolumeUp:NO];
    return YES;
}

+ (BOOL)localSetRecordVolumeDownOnWithError:(NSError **)error {
    [self sendOneTimeAction:@"set_record_volume_down_on" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRecordConfigRecordVolumeDown:YES];
    return YES;
}

+ (BOOL)localSetRecordVolumeDownOffWithError:(NSError **)error {
    [self sendOneTimeAction:@"set_record_volume_down_off" error:error]; CHECK_ERROR(NO);
    [[XXLocalDataService sharedInstance] setRecordConfigRecordVolumeDown:NO];
    return YES;
}

@end
