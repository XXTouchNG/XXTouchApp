//
//  XXRectPickerController.h
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright (c) 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"
#import "XXPickerBaseViewController.h"

@interface XXRectPickerController : XXPickerBaseViewController <XXPickerController>
@property (nonatomic, assign) CGRect currentRect;

@end
