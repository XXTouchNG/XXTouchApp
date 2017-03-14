//
//  XXUIListController.m
//  XXTouchApp
//
//  Created by Zheng on 14/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXUIListController.h"

@interface XXUIListController ()

@end

@implementation XXUIListController

- (NSString *)headerText {
    return @"Hello";
}

- (NSString *)headerSubText {
    return @"Elegant App UI provided by XXTouchApp.";
}

- (NSString *)customTitle {
    return @"Hello";
}

- (NSArray *)customSpecifiers {
    return @[
             @{
                 @"cell": @"PSGroupCell",
                 @"label": @"Example Settings"
                 },
             @{
                 @"cell": @"PSSwitchCell",
                 @"default": @YES,
                 @"defaults": @"com.xxtouch.XXTouchApp.appui-example",
                 @"key": @"enabled",
                 @"label": @"Enabled",
                 @"PostNotification": @"com.xxtouch.XXTouchApp/reloadSettings",
                 @"cellClass": @"SKTintedSwitchCell"
                 }
             ];
}

- (UIColor *)navigationTintColor {
    return [UIColor whiteColor];
}

- (UIColor *)navigationTitleTintColor {
    return [UIColor whiteColor];
}

- (UIColor *)switchTintColor {
    return STYLE_TINT_COLOR;
}

- (UIColor *)switchOnTintColor {
    return STYLE_TINT_COLOR;
}

@end
