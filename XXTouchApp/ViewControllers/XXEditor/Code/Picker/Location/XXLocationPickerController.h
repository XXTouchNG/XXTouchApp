//
//  XXLocationPickerController.h
//  XXTouchApp
//
//  Created by Zheng on 10/8/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

static NSString * const kXXLocationPickerControllerStoryboardID = @"kXXLocationPickerControllerStoryboardID";

@interface XXLocationPickerController : UIViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@end
