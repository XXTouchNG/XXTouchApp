//
//  XXInsetsLabel.m
//  XXTouchApp
//
//  Created by Zheng on 9/28/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXInsetsLabel.h"

@implementation XXInsetsLabel

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _edgeInsets)];
}

@end
