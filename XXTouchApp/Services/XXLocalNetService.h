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
@property (nonatomic, strong) NSError *lastError;

+ (id)sharedInstance;
+ (void)cleanGPSCaches;
+ (void)cleanUICaches;
+ (void)cleanAllCaches;
+ (void)respringDevice;
+ (void)restartDevice;

- (BOOL)localSetSelectedScript:(NSString *)scriptPath;
- (BOOL)localGetSelectedScript;
- (BOOL)localLaunchSelectedScript:(NSString *)scriptPath;
- (BOOL)localCleanGPSCaches;
- (BOOL)localCleanUICaches;
- (BOOL)localCleanAllCaches;
- (BOOL)localRespringDevice;
- (BOOL)localRestartDevice;

- (BOOL)localGetRemoteAccessStatus;
- (BOOL)localOpenRemoteAccess;
- (BOOL)localCloseRemoteAccess;
- (BOOL)localRestartDaemon;

@end
