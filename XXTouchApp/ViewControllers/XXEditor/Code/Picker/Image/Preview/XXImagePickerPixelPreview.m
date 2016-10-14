//
//  XXImagePickerPixelPreview.m
//  XXTouchApp
//
//  Created by Zheng on 13/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImagePickerPixelPreview.h"
#import "XXTPixelImage.h"
#import "XXImagePickerPixelPreviewRootViewController.h"

@interface XXImagePickerPixelPreview ()
@property (strong, nonatomic) XXTPixelImage *pixelImage;
@property (assign, nonatomic) CGSize pixelSize;
@property (assign, nonatomic) int hPixelNum;
@property (assign, nonatomic) int vPixelNum;

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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.pixelSize = CGSizeMake(10, 10);
    self.hPixelNum = (int)(frame.size.width / self.pixelSize.width);
    self.vPixelNum = (int)(frame.size.height / self.pixelSize.height);
}

- (void)setup {
    self.frame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = .5f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.windowLevel = UIWindowLevelAlert;
    self.rootViewController = [XXImagePickerPixelPreviewRootViewController new];
    
    self.frame = self.frame;
}

- (void)setImageToMagnify:(UIImage *)imageToMagnify {
    _imageToMagnify = imageToMagnify;
    if (!imageToMagnify) {
        _pixelImage = nil;
        return;
    }
    _pixelImage = [[XXTPixelImage alloc] initWithUIImage:imageToMagnify];
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify {
    _pointToMagnify = pointToMagnify;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGContextSetLineWidth(ctx, 0.5);
    
    int hNum = (int)(_hPixelNum / 2);
    int vNum = (int)(_vPixelNum / 2);
    CGPoint p = _pointToMagnify;
    CGSize s = _pixelSize;
    CGSize m = self.imageToMagnify.size;
    for (int i = 0; i < hNum * 2; i++) {
        for (int j = 0; j < vNum * 2; j++) {
            CGPoint t = CGPointMake(p.x - hNum + i, p.y - vNum + j);
            if (t.x < 0 || t.y < 0 || t.x > m.width || t.y > m.height) {
                CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
            } else {
                XXTColor *c = [_pixelImage getColorOfPoint:t];
                if (!c) {
                    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
                } else {
                    CGContextSetFillColorWithColor(ctx, [c getUIColor].CGColor);
                }
            }
            if (CGPointEqualToPoint(t, p)) {
                CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
            } else {
                CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
            }
            
            CGContextAddRect(ctx, CGRectMake(i * s.width, j * s.height, s.width, s.height));
            CGContextDrawPath(ctx, kCGPathFillStroke);
        }
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
