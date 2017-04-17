//
//  XUIListController.m
//  XXTouchApp
//
//  Created by Zheng on 14/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.

#import "AppDelegate.h"
#import "XUIListController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import "XXWebViewController.h"
#import "XUISpecifierParser.h"
#import <Preferences/PSSpecifier.h>

@interface XUIListController ()
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) NSDictionary *plistDict;

@end

@implementation XUIListController

- (void)viewDidLoad {
    NSString *rootPath = nil;
    
    UIViewController *parentController = nil;
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if (numberOfViewControllers < 2)
        parentController = self.navigationController.viewControllers[0];
    else
        parentController = self.navigationController.viewControllers[numberOfViewControllers - 2];
    
    if (parentController != self) {
        rootPath = [parentController performSelector:@selector(filePath)];
    } else {
        rootPath = self.filePath;
    }
    
    if (self.specifier && self.specifier.properties[@"path"]) {
        self.filePath = self.specifier.properties[@"path"];
    }
    
    [self setupAppearance];
    [super viewDidLoad];
    
    if (parentController == self) {
        if (self.title.length == 0)
            self.title = NSLocalizedString(@"DynamicXUI", nil);
        if (self.navigationController != [AppDelegate globalDelegate].window.rootViewController) {
            self.navigationItem.leftBarButtonItem = self.closeItem;
        }
    }
    if (!self.plistDict) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"Cannot parse: %@.", nil), self.filePath]];
    }
}

- (void)setupAppearance {
    
}

#pragma mark - UIView Getters

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemTapped:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

#pragma mark - Actions

- (void)closeItemTapped:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.activity && !self.activity.activeDirectly) {
            [self.activity activityDidFinish:YES];
        }
    }];
}

#pragma mark - Getters

- (NSDictionary *)plistDict {
    if (!_plistDict) {
        NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!plistDict) {
            // ? maybe JSON format
            NSError *error = nil;
            NSData *jsonData = [NSData dataWithContentsOfFile:self.filePath];
            if (jsonData) {
                plistDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            }
        }
        _plistDict = plistDict;
    }
    return _plistDict;
}

#pragma mark - List View

- (NSString *)plistName {
    return @"";
}

- (NSArray *)customSpecifiers {
    return self.plistDict[@"items"];
}

- (NSString *)customTitle {
    return self.plistDict[@"title"];
}

- (NSString *)headerText {
    return self.plistDict[@"header"];
}

- (NSString *)headerSubText {
    return self.plistDict[@"subheader"];
}

- (UIColor *)navigationTintColor {
    return [UIColor whiteColor];
}

- (UIColor *)navigationTitleTintColor {
    return [UIColor whiteColor];
}

- (UIColor *)tintColor {
    return STYLE_TINT_COLOR;
}

- (UIColor *)headerColor {
    return [UIColor blackColor];
}

- (UIColor *)switchTintColor {
    return STYLE_TINT_COLOR;
}

- (UIColor *)switchOnTintColor {
    return STYLE_TINT_COLOR;
}

#pragma mark - Keyboard

- (void)_returnKeyPressed:(NSConcreteNotification *)notification {
    [self.view endEditing:YES];
    [super _returnKeyPressed:notification];
}

#pragma mark - Button Actions

- (void)openURL:(PSSpecifier *)specifier {
    NSString *urlString = specifier.properties[@"url"];
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = @"";
    viewController.url = [NSURL URLWithString:urlString];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)runScript:(PSSpecifier *)specifier {
    NSString *path = specifier.properties[@"path"];
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = [XXLocalNetService localLaunchScript:path error:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                if (err.code == 2) {
                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[err localizedDescription] andMessage:[err localizedFailureReason]];
                    [alertView addButtonWithTitle:NSLocalizedString(@"OK", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                        
                    }];
                    [alertView show];
                } else {
                    [self.navigationController.view makeToast:[err localizedDescription]];
                }
            }
        });
    });
}

- (void)copyValue:(PSSpecifier *)specifier {
    if (specifier.properties[PSValueKey]) {
        [[UIPasteboard generalPasteboard] setString:[NSString stringWithFormat:@"%@", specifier.properties[@"value"]]];
        [self.navigationController.view makeToast:NSLocalizedString(@"Text copied to the pasteboard", nil)];
    }
}

- (void)dismissViewController {
    [self closeItemTapped:nil];
}

- (void)popViewController {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)presentViewController:(PSSpecifier *)specifier {
    if (specifier.properties[PSDetailControllerClassKey]) {
        Class className = NSClassFromString(specifier.properties[PSDetailControllerClassKey]);
        PSViewController *newController = [[className alloc] init];
        newController.specifier = specifier;
        [self.navigationController pushViewController:newController animated:YES];
    }
}

- (void)noAction {
    
}

- (void)exit {
    exit(0);
}

#pragma mark - XUITitleValueCell

- (NSString *)valueForSpecifier:(PSSpecifier *)specifier {
    if (specifier.properties[PSDefaultsKey] && specifier.properties[PSKeyNameKey]) {
        NSDictionary *configDict = [[NSDictionary alloc] initWithContentsOfFile:[specifier.properties[PSDefaultsKey] stringByAppendingPathExtension:@"plist"]];
        return [NSString stringWithFormat:@"%@", configDict[specifier.properties[PSKeyNameKey]]];
    } else if (specifier.properties[PSValueKey] && [specifier.properties[PSValueKey] isKindOfClass:[NSString class]]) {
        return specifier.properties[PSValueKey];
    }
    return @"";
}

@end
