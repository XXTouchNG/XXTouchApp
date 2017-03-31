//
//  XXBaseActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseActivity.h"

@implementation XXBaseActivity

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

+ (NSArray <NSString *> *)supportedExtensions {
    return @[];
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity
{
    [self performActivityWithController:self.baseController];
}

- (void)performActivityWithController:(UIViewController *)controller {
    self.baseController = controller;
    self.activeDirectly = YES;
}

- (void)dealloc
{
    CYLog(@"");
}

@end
