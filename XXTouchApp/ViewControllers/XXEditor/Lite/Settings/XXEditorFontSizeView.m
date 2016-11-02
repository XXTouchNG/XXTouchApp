//
//  XXEditorFontSizeView.m
//  XXTouchApp
//
//  Created by Zheng on 02/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXEditorFontSizeView.h"

@interface XXEditorFontSizeView ()
@property (nonatomic, strong) UIButton *upView;
@property (nonatomic, strong) UIButton *downView;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *ptLabel;
@property (nonatomic, strong) UILabel *upTriView;
@property (nonatomic, strong) UILabel *downTriView;

@end

@implementation XXEditorFontSizeView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = STYLE_TINT_COLOR.CGColor;
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 6.f;
    
    [self addSubview:self.sizeLabel];
    [self addSubview:self.ptLabel];
    
    UIButton *upView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height / 2)];
    upView.showsTouchWhenHighlighted = YES;
    [upView setTarget:self action:@selector(increaseFontSize:) forControlEvents:UIControlEventTouchUpInside];
    upView.backgroundColor = [UIColor clearColor];
    UILabel *upTriView = [[UILabel alloc] initWithFrame:CGRectZero];
    upTriView.font = [UIFont systemFontOfSize:14.f];
    upTriView.textColor = STYLE_TINT_COLOR;
    upTriView.text = @"▲";
    [upTriView sizeToFit];
    upTriView.center = CGPointMake(upView.width / 6 * 5, upView.height / 2);
    [upView addSubview:upTriView];
    [self addSubview:upView];
    self.upView = upView;
    
    UIButton *downView = [[UIButton alloc] initWithFrame:CGRectMake(0, self.height / 2, self.width, self.height / 2)];
    downView.showsTouchWhenHighlighted = YES;
    [downView setTarget:self action:@selector(decreaseFontSize:) forControlEvents:UIControlEventTouchUpInside];
    downView.backgroundColor = [UIColor clearColor];
    UILabel *downTriView = [[UILabel alloc] initWithFrame:CGRectZero];
    downTriView.font = [UIFont systemFontOfSize:14.f];
    downTriView.textColor = STYLE_TINT_COLOR;
    downTriView.text = @"▼";
    [downTriView sizeToFit];
    downTriView.center = CGPointMake(downView.width / 6 * 5, downView.height / 2);
    [downView addSubview:downTriView];
    [self addSubview:downView];
    self.downView = downView;
}

- (void)increaseFontSize:(UIButton *)btn {
    if (self.fontSize < MAX_FONT_SIZE) {
        self.fontSize = self.fontSize + 1;
        [self notifyChanged];
    }
}

- (void)decreaseFontSize:(UIButton *)btn {
    if (self.fontSize > MIN_FONT_SIZE) {
        self.fontSize = self.fontSize - 1;
        [self notifyChanged];
    }
}

- (void)notifyChanged {
    if (_delegate && [_delegate respondsToSelector:@selector(fontViewSizeDidChanged:)])
    {
        [_delegate fontViewSizeDidChanged:self];
    }
}

- (UILabel *)ptLabel {
    if (!_ptLabel) {
        UILabel *ptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ptLabel.font = [UIFont boldSystemFontOfSize:14.f];
        ptLabel.textColor = STYLE_TINT_COLOR;
        ptLabel.text = @"pt";
        [ptLabel sizeToFit];
        _ptLabel = ptLabel;
    }
    return _ptLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sizeLabel.font = [UIFont boldSystemFontOfSize:36.f];
        sizeLabel.textColor = STYLE_TINT_COLOR;
        _sizeLabel = sizeLabel;
    }
    return _sizeLabel;
}

- (void)setFontSize:(NSUInteger)fontSize {
    _fontSize = fontSize;
    self.sizeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.fontSize];
    [self.sizeLabel sizeToFit];
    self.sizeLabel.center = CGPointMake(self.width / 2 - self.sizeLabel.width / 2, self.height / 2);
    self.ptLabel.origin = CGPointMake(self.width / 2 + 4, self.sizeLabel.origin.y + self.sizeLabel.size.height - self.ptLabel.height);
}

@end
