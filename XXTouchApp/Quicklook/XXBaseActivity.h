//
//  XXBaseActivity.h
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXBaseActivity : UIActivity
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL activeDirectly;
@property (nonatomic, weak) UIViewController *baseController;

+ (NSArray <NSString *> *)supportedExtensions;
- (void)performActivityWithController:(UIViewController *)controller;
@end
