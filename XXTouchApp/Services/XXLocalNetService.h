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
@property (nonatomic, assign) BOOL serverAlive;

+ (id)sharedInstance;
+ (void)cleanGPSCaches;
+ (void)cleanUICaches;
+ (void)cleanAllCaches;
+ (void)respringDevice;
+ (void)restartDevice;

- (BOOL)localSetSelectedScript:(NSString *)scriptPath error:(NSError **)error;
- (BOOL)localGetSelectedScriptWithError:(NSError **)error;
- (BOOL)localLaunchSelectedScript:(NSString *)scriptPath error:(NSError **)error;
- (BOOL)localCleanGPSCachesWithError:(NSError **)error;
- (BOOL)localCleanUICachesWithError:(NSError **)error;
- (BOOL)localCleanAllCachesWithError:(NSError **)error;
- (BOOL)localRespringDeviceWithError:(NSError **)error;
- (BOOL)localRestartDeviceWithError:(NSError **)error;

- (BOOL)localGetRemoteAccessStatusWithError:(NSError **)error;
- (BOOL)localOpenRemoteAccessWithError:(NSError **)error;
- (BOOL)localCloseRemoteAccessWithError:(NSError **)error;
- (BOOL)localRestartDaemonWithError:(NSError **)error;

- (BOOL)localGetDeviceAuthInfoWithError:(NSError **)error;
- (BOOL)localGetDeviceInfoWithError:(NSError **)error;
- (BOOL)localBindCode:(NSString *)bind error:(NSError **)error;

@end
