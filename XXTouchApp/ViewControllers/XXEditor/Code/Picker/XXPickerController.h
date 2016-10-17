//
//  XXPickerController.h
//  XXTouchApp
//
//  Created by Zheng on 17/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXCodeBlockModel.h"

@protocol XXPickerController <NSObject>

@required
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@required
@property (nonatomic, strong) UIViewController *processController;

@required
@property (nonatomic, copy) NSString *keyword;

@required
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@required
- (void)next:(UIBarButtonItem *)sender;

@required
- (void)pushToNextControllerWithKeyword:(NSString *)keyword
                            replacement:(NSString *)replace;

@required
- (NSString *)previewString;

@required
- (NSString *)subtitle;

@end
