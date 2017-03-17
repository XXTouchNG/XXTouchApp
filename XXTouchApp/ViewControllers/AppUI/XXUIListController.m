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
#import "XXWebViewController.h"

@interface XXUIListController ()
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (nonatomic, strong) NSDictionary *plistDict;

@end

@implementation XXUIListController

- (void)viewDidLoad {
    UIViewController *rootController = self.navigationController.viewControllers[0];
    if (rootController != self) {
        self.filePath = [rootController performSelector:@selector(filePath)];
    }
    [super viewDidLoad];
    if (rootController == self) {
        if (self.title.length == 0) {
            self.title = NSLocalizedString(@"AppUI", nil);
        }
        self.navigationItem.leftBarButtonItem = self.closeItem;
        self.navigationItem.rightBarButtonItem = self.saveItem;
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

- (UIBarButtonItem *)saveItem {
    if (!_saveItem) {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveItemTapped:)];
        saveItem.tintColor = [UIColor whiteColor];
        _saveItem = saveItem;
    }
    return _saveItem;
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

- (void)saveItemTapped:(UIBarButtonItem *)sender {
    NSString *prefsDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Preferences"];
    NSString *targetDir = [[[XXLocalDataService sharedInstance] mainPath] stringByAppendingPathComponent:@"uicfg"];
    NSFileManager *sharedManager = [NSFileManager defaultManager];
    NSError *err = nil;
    for (PSSpecifier *specifier in self.specifiers) {
        if (specifier.properties[@"defaults"]) {
            NSString *originalPref = [[prefsDir stringByAppendingPathComponent:specifier.properties[@"defaults"]] stringByAppendingPathExtension:@"plist"];
            NSString *targetPref = [[targetDir stringByAppendingPathComponent:specifier.properties[@"defaults"]] stringByAppendingPathExtension:@"plist"];
            if ([sharedManager fileExistsAtPath:originalPref]) {
                NSString *destinationPref = [sharedManager destinationOfSymbolicLinkAtPath:targetPref error:&err];
                if (destinationPref) {
                    if ([destinationPref isEqualToString:originalPref]) {
                        continue;
                    } else {
                        [sharedManager removeItemAtPath:targetPref error:&err];
                    }
                } else {
                    err = nil;
                }
                if (![sharedManager fileExistsAtPath:targetDir]) {
                    [sharedManager createDirectoryAtPath:targetDir withIntermediateDirectories:YES attributes:nil error:&err];
                }
                [sharedManager createSymbolicLinkAtPath:targetPref withDestinationPath:originalPref error:&err];
            }
        }
        if (err) {
            break;
        }
    }
    if (!err) {
        [self closeItemTapped:sender];
    } else {
        [self.navigationController.view makeToast:[err localizedDescription]];
    }
}

#pragma mark - Getters

- (NSDictionary *)plistDict {
    if (!_plistDict) {
        NSString *plistPath = nil;
        if (self.specifier) {
            if (self.specifier.properties[@"path"]) {
                NSURL *fileURL = [[NSURL alloc] initWithString:self.specifier.properties[@"path"]
                                                 relativeToURL:[NSURL URLWithString:self.filePath]];
                self.filePath = [fileURL path];
            }
        }
        plistPath = self.filePath;
        NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
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

- (void)url {
    // Nothing will be performed
}

@end
