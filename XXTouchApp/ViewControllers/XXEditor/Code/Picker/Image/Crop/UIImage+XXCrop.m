//
//  UIImage+PECrop.m
//  PhotoCropEditor
//
//  Created by Ernesto Rivera on 2013/07/29.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "UIImage+XXCrop.h"

@implementation UIImage (XXCrop)

- (UIImage *)rotatedImageWithtransform:(CGAffineTransform)rotation
                         croppedToRect:(CGRect)rect
{
    UIImage *rotatedImage = [self xx_rotatedImageWithtransform:rotation];
    
    CGFloat scale = rotatedImage.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    return image;
}

- (UIImage *)xx_rotatedImageWithtransform:(CGAffineTransform)transform
{
    CGSize size = self.size;
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           NO,                     // Not Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

@end
