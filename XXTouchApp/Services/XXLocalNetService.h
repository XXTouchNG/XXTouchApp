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
+ (void)respringDevice;
- (BOOL)localSetSelectedScript:(NSString *)scriptPath;
- (BOOL)localGetSelectedScript;
@end
