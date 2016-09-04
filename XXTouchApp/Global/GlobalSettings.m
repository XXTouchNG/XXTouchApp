//
//  GlobalSettings.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "GlobalSettings.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"

@implementation GlobalSettings

+ (id)sharedInstance {
    static GlobalSettings *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupStyle];
        [XXLocalNetService sharedInstance];
        [XXLocalDataService sharedInstance];
    }
    return self;
}

- (void)setupStyle {
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setDefaultDuration:STYLE_TOAST_DURATION];
    [CSToastManager setQueueEnabled:NO];
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    
    [SIAlertView appearance].transitionStyle = SIAlertViewTransitionStyleBounce;
    [SIAlertView appearance].titleFont = [UIFont boldSystemFontOfSize:18.f];
    [SIAlertView appearance].messageFont = [UIFont systemFontOfSize:14.f];
    [SIAlertView appearance].buttonFont = [UIFont systemFontOfSize:14.f];
}

@end
