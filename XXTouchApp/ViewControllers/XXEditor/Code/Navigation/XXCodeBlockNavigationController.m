//
//  XXCodeBlockNavigationController.m
//  XXTouchApp
//
//  Created by Zheng on 13/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockNavigationController.h"
#import "XXPickerBaseViewController.h"
#import <Masonry/Masonry.h>

@interface XXCodeBlockNavigationController () <UINavigationControllerDelegate>

@end

@implementation XXCodeBlockNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    [self.view addSubview:self.popupBar];
    [self updateViewConstraints];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.popupBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
}

#pragma mark - Navigation Events

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController == self) {
        if ([viewController isKindOfClass:[XXPickerBaseViewController class]]) {
            XXPickerBaseViewController *pickerController = (XXPickerBaseViewController *)viewController;
            self.popupBar.hidden = NO;
            [self.view bringSubviewToFront:self.popupBar];
            if ([pickerController respondsToSelector:@selector(tableView)]) {
                UITableViewController *tablePickerController = (UITableViewController *)viewController;
                UIEdgeInsets insets = tablePickerController.tableView.contentInset;
                insets.bottom = self.popupBar.height;
                tablePickerController.tableView.contentInset =
                tablePickerController.tableView.scrollIndicatorInsets = insets;
            }
            self.popupBar.title = [NSString stringWithFormat:@"%@ (%ld/%ld)", pickerController.title, (unsigned long)pickerController.codeBlock.currentStep, (unsigned long)pickerController.codeBlock.totalStep];
            if (pickerController.subtitle) {
                self.popupBar.subtitle = pickerController.subtitle;
            }
            self.popupBar.progress = (float)pickerController.codeBlock.currentStep / pickerController.codeBlock.totalStep;
        } else {
            self.popupBar.hidden = YES;
        }
    }
}

#pragma mark - Popup Bar

- (XXPickerPopupBar *)popupBar {
    if (!_popupBar) {
        XXPickerPopupBar *popupBar = [[XXPickerPopupBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 44)];
        popupBar.hidden = YES;
        _popupBar = popupBar;
    }
    return _popupBar;
}

@end
