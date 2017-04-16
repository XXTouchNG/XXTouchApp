//
//  XXPositionColorModel.m
//  XXTouchApp
//
//  Created by Zheng on 20/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPositionColorModel.h"

@implementation XXPositionColorModel

+ (instancetype)modelWithPosition:(CGPoint)p andColor:(UIColor *)c {
    XXPositionColorModel *newModel = [XXPositionColorModel new];
    newModel.position = p;
    newModel.color = c;
    return newModel;
}

@end
