//
//  XXTColor.h
//  XXTPixelImage
//
//  Created by 苏泽 on 16/8/2.
//  Copyright © 2016年 苏泽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XXTColor : NSObject
{
    uint8_t _red;
    uint8_t _green;
    uint8_t _blue;
    uint8_t _alpha;
}

@property uint8_t red;
@property uint8_t green;
@property uint8_t blue;
@property uint8_t alpha;

+ (XXTColor *)colorWithRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue alpha:(uint8_t)alpha;
+ (XXTColor *)colorWithUIColor:(UIColor *)uicolor;
- (uint32_t)getColor;
- (uint32_t)getColorAlpha;
- (NSString *)getColorHex;
- (NSString *)getColorHexAlpha;
- (UIColor *)getUIColor;
- (void)setRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue alpha:(uint8_t)alpha;
- (void)setColorWithUIColor:(UIColor *)uicolor;

@end
