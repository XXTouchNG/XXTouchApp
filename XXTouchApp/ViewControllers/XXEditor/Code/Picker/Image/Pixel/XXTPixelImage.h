//
//  XXTPixelImage.h
//  XXTPixelImage
//
//  Created by 苏泽 on 16/8/1.
//  Copyright © 2016年 苏泽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XXTColor.h"

typedef struct SZ_IMAGE SZ_IMAGE;

@interface XXTPixelImage : NSObject
{
    SZ_IMAGE *_pixel_image;
}

@property uint8_t orient;

+ (XXTPixelImage *)imageWithUIImage:(UIImage *)uiimage;
- (XXTPixelImage *)initWithUIImage:(UIImage *)uiimage;
- (XXTColor *)getColorOfPoint:(CGPoint)point;
- (NSString *)getColorHexOfPoint:(CGPoint)point;
- (void)setColor:(XXTColor *)color ofPoint:(CGPoint)point;
- (UIImage *)getUIImage;

@end
