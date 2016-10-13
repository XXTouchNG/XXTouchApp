//
//  XXCodeBlockNavigationController.m
//  XXTouchApp
//
//  Created by Zheng on 13/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockNavigationController.h"

@interface XXCodeBlockNavigationController ()
@property (nonatomic, assign) BOOL fullscreenGuide;

@end

@implementation XXCodeBlockNavigationController

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    if (!_fullscreenGuide && hidden) {
        _fullscreenGuide = YES;
        [self.view makeToast:NSLocalizedString(@"Double fingers tap to exit fullscreen", nil)
                    duration:STYLE_TOAST_DURATION
                    position:CSToastPositionBottom];
    }
}

@end
