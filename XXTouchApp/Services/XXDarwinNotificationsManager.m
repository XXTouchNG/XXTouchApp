//
//  XXDarwinNotificationsManager.m
//  XXTouchApp
//
//  Created by Zheng on 19/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXDarwinNotificationsManager.h"

@implementation XXDarwinNotificationsManager {
    NSMutableDictionary * handlers;
}

+ (instancetype)sharedInstance {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDrop);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                                  void *observer,
                                  CFStringRef name,
                                  const void *object,
                                  CFDictionaryRef userInfo)
{
    NSString *identifier = (__bridge NSString *)name;
    [[XXDarwinNotificationsManager sharedInstance] notificationCallbackReceivedWithName:identifier];
}


- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}

@end
