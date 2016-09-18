//
//  XXScanLineAnimation.h
//  XXTouchApp
//
//  Created by Zheng on 9/18/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXScanLineAnimation : UIImageView
@property (nonatomic, assign) BOOL isAnimating;

- (void)startAnimatingWithRect:(CGRect)animationRect
                    parentView:(UIView *)parentView;
- (void)stopAnimating;

@end
