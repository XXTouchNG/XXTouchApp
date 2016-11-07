//
//  UIViewController+MSLayoutSupport.h
//  XXTouchApp
//
//  Created by Zheng on 9/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MSLayoutSupport)
- (id<UILayoutSupport>)ms_navigationBarTopLayoutGuide;
- (id<UILayoutSupport>)ms_navigationBarBottomLayoutGuide;
@end
