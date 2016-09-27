//
//  XXCodeBlockModel.m
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockModel.h"

@implementation XXCodeBlockModel

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code {
    return [self modelWithTitle:title code:code type:kXXCodeBlockTypeInternalFunction];
}

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code type:(kXXCodeBlockType)type {
    XXCodeBlockModel *newModel = [XXCodeBlockModel new];
    newModel.title = title;
    newModel.code = code;
    newModel.type = type;
    return newModel;
}

@end
