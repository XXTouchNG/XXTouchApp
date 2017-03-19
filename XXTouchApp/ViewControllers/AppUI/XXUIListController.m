//
//  XXUIListController.m
//  XXTouchApp
//
//  Created by Zheng on 14/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.

// References to:
//  http://iphonedevwiki.net/index.php/Preferences_specifier_plist

// Available Cell Types:
// PSButtonCell
// PSEditTextCell & PSSecureEditTextCell
// PSGroupCell
// PSLinkCell
// PSLinkListCell & PSSegmentCell
// PSSliderCell
// PSStaticTextCell
// PSSwitchCell
// PSTitleValueCell
// PSImageCell

#import "XXUIListController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import "XXWebViewController.h"
#import "XXUISpecifierParser.h"

@interface XXUIListController ()
@property (nonatomic, strong) UIBarButtonItem *closeItem;
//@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (nonatomic, strong) NSDictionary *plistDict;

@end

@implementation XXUIListController

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
    
    [super viewDidLoad];
    
    if (parentController == self) {
        if (self.title.length == 0)
            self.title = NSLocalizedString(@"AppUI", nil);
        self.navigationItem.leftBarButtonItem = self.closeItem;
    }
    if (!self.plistDict) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"Cannot parse: %@.", nil), self.filePath]];
    }
}

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
    // nav title
    return self.plistDict[@"title"];
}

- (NSString *)headerText {
    // header title
    return self.plistDict[@"header"];
}

- (NSString *)headerSubText {
    // header subtitle
    return self.plistDict[@"subheader"];
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

#pragma mark - Keyboard

- (void)_returnKeyPressed:(NSConcreteNotification *)notification {
    [self.view endEditing:YES];
    [super _returnKeyPressed:notification];
}

#pragma mark - Button Actions

- (void)url:(PSSpecifier *)specifier {
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

- (void)close {
    [self closeItemTapped:nil];
}

- (void)back {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - XXUITitleValueCell

- (NSString *)valueForSpecifier:(PSSpecifier *)specifier {
    if (specifier.properties[@"defaults"] && specifier.properties[@"key"]) {
        NSDictionary *configDict = [[NSDictionary alloc] initWithContentsOfFile:[specifier.properties[@"defaults"] stringByAppendingPathExtension:@"plist"]];
        return [NSString stringWithFormat:@"%@", configDict[specifier.properties[@"key"]]];
    } else if (specifier.properties[@"value"] && [specifier.properties[@"value"] isKindOfClass:[NSString class]]) {
        return specifier.properties[@"value"];
    }
    return @"";
}

@end
