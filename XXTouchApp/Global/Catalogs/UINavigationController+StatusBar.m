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
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}
- (NSUInteger)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}
@end
