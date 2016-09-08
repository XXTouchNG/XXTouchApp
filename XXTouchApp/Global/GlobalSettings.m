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
#import "XXQuickLookService.h"

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
        [self setupMedia];
        [XXLocalNetService sharedInstance];
        [XXLocalDataService sharedInstance];
        [XXQuickLookService sharedInstance];
    }
    return self;
}

- (void)setupStyle {
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setDefaultDuration:STYLE_TOAST_DURATION];
    [CSToastManager setQueueEnabled:NO];
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    
    [CSToastManager sharedStyle].backgroundColor = [UIColor colorWithWhite:0.f alpha:.6f];
    [CSToastManager sharedStyle].titleFont = [UIFont boldSystemFontOfSize:14.f];
    [CSToastManager sharedStyle].messageFont = [UIFont systemFontOfSize:14.f];
    
    [SIAlertView appearance].transitionStyle = SIAlertViewTransitionStyleBounce;
    [SIAlertView appearance].titleFont = [UIFont boldSystemFontOfSize:18.f];
    [SIAlertView appearance].messageFont = [UIFont systemFontOfSize:14.f];
    [SIAlertView appearance].buttonFont = [UIFont systemFontOfSize:14.f];
}

- (void)setupMedia {
    
}

@end
