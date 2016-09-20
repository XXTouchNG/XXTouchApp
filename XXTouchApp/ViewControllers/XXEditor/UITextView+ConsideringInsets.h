//
//  UITextView+ConsideringInsets.h
//  XXTouchApp
//
//  Created by Zheng on 9/20/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (ConsideringInsets)

- (void)scrollRangeToMiddle:(NSRange)range height:(CGFloat)height;

// Scrolls to visible range, eventually considering insets
- (void)scrollRangeToVisible:(NSRange)range consideringInsets:(BOOL)considerInsets;

// Scrolls to visible rect, eventually considering insets
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated consideringInsets:(BOOL)considerInsets;

// Returns visible rect, eventually considering insets
- (CGRect)visibleRectConsideringInsets:(BOOL)considerInsets;

@end
