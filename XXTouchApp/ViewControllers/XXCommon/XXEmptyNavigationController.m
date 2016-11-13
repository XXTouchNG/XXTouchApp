//
//  XXEmptyNavigationController.m
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXEmptyNavigationController.h"

@interface XXEmptyNavigationController ()
@property (nonatomic, assign) BOOL fullscreenGuide;

@end

@implementation XXEmptyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor = STYLE_TINT_COLOR;
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    
    if (hidden && !_fullscreenGuide) {
        _fullscreenGuide = YES;
        [self.view makeToast:NSLocalizedString(@"Triple touches to exit fullscreen", nil)];
    }
}

@end
