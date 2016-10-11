//
//  XXMixedPickerController.h
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright (c) 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

typedef enum : NSUInteger {
    kXXImagePickerTypePosition = 0,
    kXXImagePickerTypeColor = 1,
    kXXImagePickerTypeMixed = 2,
    kXXImagePickerTypeRect = 3
} kXXImagePickerType;

@interface XXMixedPickerController : UIViewController
@property (nonatomic, assign) kXXImagePickerType pickerType;
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@end
