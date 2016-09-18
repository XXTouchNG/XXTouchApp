//
//  XXScanLineAnimation.m
//  XXTouchApp
//
//  Created by Zheng on 9/18/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXScanLineAnimation.h"

@interface XXScanLineAnimation ()

@property (nonatomic, assign) CGRect animationRect;

@end

@implementation XXScanLineAnimation

- (void)stepAnimation {
    if (!_isAnimating) {
        return;
    }
    
    CGFloat leftX = _animationRect.origin.x + 5;
    CGFloat width = _animationRect.size.width - 10;
    
    self.frame = CGRectMake(leftX, _animationRect.origin.y + 8, width, 8);
    self.alpha = 0.0;
    self.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 1.0;
    } completion:nil];
    
    [UIView animateWithDuration:3.f animations:^{
        CGFloat leftX = _animationRect.origin.x + 5;
        CGFloat width = _animationRect.size.width - 10;
        weakSelf.frame = CGRectMake(leftX, _animationRect.origin.y + _animationRect.size.height - 8, width, 4);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [weakSelf performSelector:@selector(stepAnimation) withObject:nil afterDelay:0.3];
    }];
}


- (void)startAnimatingWithRect:(CGRect)animationRect parentView:(UIView *)parentView
{
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    _animationRect = animationRect;
    
    [parentView addSubview:self];
    [self startAnimating_UIViewAnimation];
}

- (void)startAnimating_UIViewAnimation {
    [self stepAnimation];
}

- (void)dealloc {
    [self stopAnimating];
}

- (void)stopAnimating {
    if (_isAnimating) {
        _isAnimating = NO;
        [self removeFromSuperview];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
