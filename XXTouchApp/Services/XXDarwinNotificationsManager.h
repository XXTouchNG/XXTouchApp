//
//  XXDarwinNotificationsManager.h
//  XXTouchApp
//
//  Created by Zheng on 19/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DarwinNotifications_h
#define DarwinNotifications_h

@interface XXDarwinNotificationsManager : NSObject

@property (strong, nonatomic) id someProperty;

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;

@end

#endif
