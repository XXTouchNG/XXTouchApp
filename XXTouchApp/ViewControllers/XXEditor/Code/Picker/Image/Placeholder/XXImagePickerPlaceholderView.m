//
//  XXImagePickerPlaceholderView.m
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImagePickerPlaceholderView.h"

@implementation XXImagePickerPlaceholderView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

@end
