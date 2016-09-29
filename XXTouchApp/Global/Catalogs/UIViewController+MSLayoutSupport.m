//
//  UIViewController+MSLayoutSupport.m
//  XXTouchApp
//
//  Created by Zheng on 9/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "UIViewController+MSLayoutSupport.h"

@implementation UIViewController (MSLayoutSupport)

- (id<UILayoutSupport>)ms_navigationBarTopLayoutGuide {
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return self.parentViewController.ms_navigationBarTopLayoutGuide;
    } else {
        return self.topLayoutGuide;
    }
}

- (id<UILayoutSupport>)ms_navigationBarBottomLayoutGuide {
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return self.parentViewController.ms_navigationBarBottomLayoutGuide;
    } else {
        return self.bottomLayoutGuide;
    }
}

@end
