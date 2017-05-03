//
//  UIImage+imageData.m
//  XXTPickerCollection
//
//  Created by Zheng on 03/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "UIImage+imageData.h"

@implementation UIImage (imageData)

+ (UIImage *)imageWithImageData:(NSData *)imageData {
    NSInteger lenth =  imageData.length;
    NSInteger width = 87;
    NSInteger height = 87;
    uint32_t *pixels = (uint32_t *)malloc(width * height * sizeof(uint32_t));
    [imageData getBytes:pixels range:NSMakeRange(32, lenth - 32)];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(pixels, width, height, 8, (width + 1) * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    UIImage *icon = [UIImage imageWithCGImage: cgImage];
    CGImageRelease(cgImage);
    
    return icon;
}

@end
