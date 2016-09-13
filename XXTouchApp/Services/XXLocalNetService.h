//
//  XXLocalNetService.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXLocalDefines.h"

@interface XXLocalNetService : NSObject

+ (BOOL)localSetSelectedScript:(NSString *)scriptPath error:(NSError **)error;
+ (BOOL)localGetSelectedScriptWithError:(NSError **)error;
+ (BOOL)localLaunchSelectedScript:(NSString *)scriptPath error:(NSError **)error;
+ (BOOL)localCleanGPSCachesWithError:(NSError **)error;
+ (BOOL)localCleanUICachesWithError:(NSError **)error;
+ (BOOL)localCleanAllCachesWithError:(NSError **)error;
+ (BOOL)localRespringDeviceWithError:(NSError **)error;
+ (BOOL)localRestartDeviceWithError:(NSError **)error;

+ (BOOL)localGetRemoteAccessStatusWithError:(NSError **)error;
+ (BOOL)localOpenRemoteAccessWithError:(NSError **)error;
+ (BOOL)localCloseRemoteAccessWithError:(NSError **)error;
+ (BOOL)localRestartDaemonWithError:(NSError **)error;

+ (BOOL)localGetDeviceAuthInfoWithError:(NSError **)error;
+ (BOOL)localGetDeviceInfoWithError:(NSError **)error;
+ (BOOL)localBindCode:(NSString *)bind error:(NSError **)error;

+ (BOOL)localGetApplicationListWithError:(NSError **)error;
+ (BOOL)localClearAppData:(NSString *)bid error:(NSError **)error;

+ (BOOL)localGetVolumeActionConfWithError:(NSError **)error;
+ (BOOL)localSetHoldVolumeUpAction:(NSUInteger)option error:(NSError **)error;
+ (BOOL)localSetHoldVolumeDownAction:(NSUInteger)option error:(NSError **)error;
+ (BOOL)localSetPressVolumeUpAction:(NSUInteger)option error:(NSError **)error;
+ (BOOL)localSetPressVolumeDownAction:(NSUInteger)option error:(NSError **)error;

+ (BOOL)localGetRecordConfWithError:(NSError **)error;
+ (BOOL)localSetRecordVolumeUpOnWithError:(NSError **)error;
+ (BOOL)localSetRecordVolumeUpOffWithError:(NSError **)error;
+ (BOOL)localSetRecordVolumeDownOnWithError:(NSError **)error;
+ (BOOL)localSetRecordVolumeDownOffWithError:(NSError **)error;

+ (BOOL)localGetStartUpConfWithError:(NSError **)error;
+ (BOOL)localSetStartUpRunOnWithError:(NSError **)error;
+ (BOOL)localSetStartUpRunOffWithError:(NSError **)error;

@end
