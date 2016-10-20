//
//  XXImageFlagView.m
//  XXTouchApp
//
//  Created by Zheng on 20/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImageFlagView.h"

@interface XXImageFlagView ()
@property (nonatomic, strong) UILabel *hahaLabel;

@end

@implementation XXImageFlagView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (UILabel *)hahaLabel {
    if (!_hahaLabel) {
        UILabel *hahaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        hahaLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        hahaLabel.text = @"🐸";
        hahaLabel.textAlignment = NSTextAlignmentCenter;
        [hahaLabel sizeToFit];
        _hahaLabel = hahaLabel;
    }
    return _hahaLabel;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.hahaLabel];
}

//- (void)drawRect:(CGRect)rect {
//    
//}

@end
