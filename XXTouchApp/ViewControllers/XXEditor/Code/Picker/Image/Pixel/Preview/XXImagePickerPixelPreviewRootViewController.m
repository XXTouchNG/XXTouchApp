//
//  XXImagePickerPixelPreviewRootViewController.m
//  XXTouchApp
//
//  Created by Zheng on 14/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImagePickerPixelPreviewRootViewController.h"

@implementation XXImagePickerPixelPreviewRootViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

#pragma mark - View Style

- (BOOL)shouldAutorotate {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return NO;
    }
    return YES;
}

@end
