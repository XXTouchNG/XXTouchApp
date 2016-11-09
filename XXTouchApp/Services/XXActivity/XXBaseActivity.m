//
//  XXBaseActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseActivity.h"

@implementation XXBaseActivity

- (instancetype)initWithViewController:(UIViewController *)controller {
    if (self = [super init]) {
        self.baseController = controller;
    }
    return self;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count >= 1) {
        if ([activityItems[0] isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count >= 1) {
        if ([activityItems[0] isKindOfClass:[NSURL class]]) {
            self.fileURL = activityItems[0];
        }
    }
}

- (UIViewController *)activityViewController
{
    return nil;
}

+ (NSArray <NSString *> *)supportedExtensions {
    return @[];
}

@end
