//
//  XXBaseTextView.h
//  XXTouchApp
//
//  Created by Zheng on 9/19/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "CYRTextView.h"

@interface XXBaseTextView : CYRTextView
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIFont *italicFont;
@property (nonatomic, strong) UIFont *boldItalicFont;

- (id)initWithFrame:(CGRect)frame lineNumbersEnabled:(BOOL)lineNumbersEnabled;
- (void)setHighlightLuaSymbols:(BOOL)highlightLuaSymbols;
@end
