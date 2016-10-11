//
//  XXImagePickerPlaceholderView.m
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImagePickerPlaceholderView.h"
#import <Masonry/Masonry.h>

@interface XXImagePickerPlaceholderView ()
@property (nonatomic, strong) UIImageView *centerAddImage;
@property (nonatomic, strong) UILabel *centerAddLabel;

@end

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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    [_centerAddImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    [_centerAddLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self->_centerAddImage.mas_bottom).offset(24);
    }];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *centerAddImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"picker-marquee"] imageByTintColor:[UIColor colorWithWhite:0.94f alpha:1.f]]];
    [self addSubview:centerAddImage];
    _centerAddImage = centerAddImage;
    
    UILabel *centerAddLabel = [[UILabel alloc] init];
    centerAddLabel.textColor = [UIColor colorWithWhite:0.8f alpha:1.f];
    centerAddLabel.font = [UIFont systemFontOfSize:12.f];
    centerAddLabel.textAlignment = NSTextAlignmentCenter;
    centerAddLabel.numberOfLines = 2;
    centerAddLabel.lineBreakMode = NSLineBreakByWordWrapping;
    centerAddLabel.text = NSLocalizedString(@"No image\nTap here to add", nil);
    [centerAddLabel sizeToFit];
    [self addSubview:centerAddLabel];
    _centerAddLabel = centerAddLabel;
}

@end
