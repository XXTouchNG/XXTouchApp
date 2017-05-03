//
//  XXTPickerHelper.h
//  XXTPickerCollection
//
//  Created by Zheng on 30/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXTPickerHelper : NSObject

@property (nonatomic, weak) id callbackObject;
@property (nonatomic, assign) SEL callbackSelector;
@property (nonatomic, strong) UIColor *frontColor;

+ (instancetype)sharedInstance;
+ (NSBundle *)bundle;
- (void)performNextStep:(UIViewController *)viewController;
- (void)performFinished:(UIViewController *)viewController;
- (void)performUpdateStep:(UIViewController *)viewController;

@end
