//
//  XXSearchBar.m
//  XXTouchApp
//
//  Created by Zheng on 13/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXSearchBar.h"

@implementation XXSearchBar

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
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.barTintColor = [UIColor whiteColor];
    self.tintColor = STYLE_TINT_COLOR;
    self.placeholder = NSLocalizedString(@"Search", nil);
    self.scopeButtonTitles = @[ NSLocalizedString(@"Normal", nil), NSLocalizedString(@"Regex", nil) ];
    self.showsScopeBar = YES;
    [self sizeToFit];
}

@end
