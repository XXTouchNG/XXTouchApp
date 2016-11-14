//
//  XXFeatureTableViewCell.m
//  XXTouchApp
//
//  Created by Zheng on 13/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXFeatureTableViewCell.h"
#import <Masonry/Masonry.h>

@interface XXFeatureTableViewCell ()
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation XXFeatureTableViewCell

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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self addSubview:self.titleImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(22);
        make.top.equalTo(self).offset(18);
        make.width.equalTo(@(128));
        make.height.equalTo(@(92));
    }];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImageView.mas_right).offset(16);
        make.top.equalTo(self.titleImageView).offset(4);
        make.height.equalTo(@(16));
        make.right.equalTo(self).offset(-22);
    }];
    [self.subtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.right.equalTo(self).offset(-22);
        make.bottom.equalTo(self).offset(-18);
    }];
}

#pragma mark - Getters

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 128.f, 92.f)];
        titleImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"crop-pattern"]];
        titleImageView.layer.cornerRadius = 6.f;
        titleImageView.layer.borderWidth = 1.f;
        titleImageView.layer.borderColor = [UIColor colorWithWhite:.75f alpha:1.f].CGColor;
        _titleImageView = titleImageView;
    }
    return _titleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        titleLabel.text = NSLocalizedString(@"Feature Title", nil);
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font = [UIFont systemFontOfSize:12.f];
        subtitleLabel.numberOfLines = 4;
        subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subtitleLabel.text = NSLocalizedString(@"Feature Sub-title", nil);
        _subtitleLabel = subtitleLabel;
    }
    return _subtitleLabel;
}

#pragma mark - Setters

- (void)setTitleImage:(UIImage *)titleImage {
    _titleImage = titleImage;
    self.titleImageView.backgroundColor = [UIColor clearColor];
    [self.titleImageView setImage:[titleImage imageByTintColor:[UIColor colorWithWhite:0.3f alpha:1.f]]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.titleLabel setText:title];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    [self.subtitleLabel setText:subtitle];
}

@end
