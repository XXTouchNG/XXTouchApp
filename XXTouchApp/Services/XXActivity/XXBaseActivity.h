//
//  XXBaseActivity.h
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXBaseActivity : UIActivity
@property (nonatomic, weak) UIViewController *baseController;
@property (nonatomic, strong) NSURL *fileURL;

- (instancetype)initWithViewController:(UIViewController *)controller;
+ (NSArray <NSString *> *)supportedExtensions;
- (void)presentActivity;

@end
