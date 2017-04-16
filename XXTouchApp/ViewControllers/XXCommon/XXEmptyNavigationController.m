//
//  XXEmptyNavigationController.m
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXEmptyNavigationController.h"

@interface XXEmptyNavigationController ()
@property (nonatomic, assign) BOOL keyboardGuide;

@end

@implementation XXEmptyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = STYLE_TINT_COLOR;
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    if (!_keyboardGuide && hidden) {
        _keyboardGuide = YES;
        [self.view makeToast:NSLocalizedString(@"Slide down to exit edit mode", nil)
                    duration:3.f
                    position:CSToastPositionTop];
    }
}

@end
