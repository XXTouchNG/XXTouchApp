//
//  UINavigationController+StatusBar.m
//  Courtesy
//
//  Created by Zheng on 8/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "UINavigationController+StatusBar.h"

@implementation UINavigationController (StatusBar)
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

#pragma mark - View Style

- (BOOL)shouldAutorotate {
    if (XXT_SYSTEM_8) {
        return self.topViewController.shouldAutorotate;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (XXT_SYSTEM_8) {
        return self.topViewController.supportedInterfaceOrientations;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
