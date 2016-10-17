//
//  XXPickerPopupBar.m
//  XXTouchApp
//
//  Created by Zheng on 18/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPickerPopupBar.h"

@interface XXPickerPopupBar ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation XXPickerPopupBar

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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, self.frame.size.width, 18)];
        titleLabel.font = [UIFont boldSystemFontOfSize:12.f];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 1;
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, self.frame.size.width, 18)];
        subtitleLabel.font = [UIFont systemFontOfSize:12.f];
        subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.numberOfLines = 1;
        _subtitleLabel = subtitleLabel;
    }
    return _subtitleLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 43, self.frame.size.width, 1)];
        progressView.progressTintColor = STYLE_TINT_COLOR;
        _progressView = progressView;
    }
    return _progressView;
}

- (void)setup {
    self.tintColor = STYLE_TINT_COLOR;
    self.backgroundColor = [UIColor clearColor];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.f alpha:.75f]]
          forToolbarPosition:UIBarPositionAny
                  barMetrics:UIBarMetricsDefault];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.progressView];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    self.progressView.progress = progress;
}

@end
