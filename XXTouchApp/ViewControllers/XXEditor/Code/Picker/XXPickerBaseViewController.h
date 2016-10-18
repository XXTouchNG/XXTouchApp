//
//  XXPickerBaseViewController.h
//  XXTouchApp
//
//  Created by Zheng on 17/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

@interface XXPickerBaseViewController : UIViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;
@property (nonatomic, strong) UIViewController *processController;

@property (nonatomic, strong) UIBarButtonItem *nextButton;
- (void)next:(UIBarButtonItem *)sender;
- (void)pushToNextControllerWithKeyword:(NSString *)keyword
                            replacement:(NSString *)replace;

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *previewString;

@end
