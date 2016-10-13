//
//  XXImagePickerPixelPreview.m
//  XXTouchApp
//
//  Created by Zheng on 13/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImagePickerPixelPreview.h"

@interface XXImagePickerPixelPreview ()
@property (strong, nonatomic) CALayer *contentLayer;

@end

@implementation XXImagePickerPixelPreview

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.frame = CGRectMake(0, 0, 120, 120);
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = .5f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.windowLevel = UIWindowLevelAlert;
    
    self.contentLayer = [CALayer layer];
    self.contentLayer.frame = self.bounds;
    self.contentLayer.delegate = self;
    self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer addSublayer:self.contentLayer];
    
    self.scaleValue = 20.f;
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify {
    _pointToMagnify = pointToMagnify;
    
    CGPoint center = CGPointMake(pointToMagnify.x, self.center.y);
    if (pointToMagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointToMagnify.y -  CGRectGetHeight(self.bounds) / 2;
    }
    
    self.center = center;
    [self.contentLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, self.scaleValue, self.scaleValue);
    CGContextTranslateCTM(ctx, -1 * self.pointToMagnify.x, -1 * self.pointToMagnify.y);
    [self.viewToMagnify.layer renderInContext:ctx];
}

@end
