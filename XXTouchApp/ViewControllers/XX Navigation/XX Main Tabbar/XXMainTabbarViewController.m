//
//  XXMainTabbarViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXMainTabbarViewController.h"

@interface XXMainTabbarViewController () <UITabBarControllerDelegate>

@end

@implementation XXMainTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"My Scripts", @"XXTouch", nil);
    self.delegate = self;
    
    self.tabBar.selectedImageTintColor = STYLE_TINT_COLOR;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTabbarItems:self.selectedViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
    [self reloadTabbarItems:viewController];
}

- (void)reloadTabbarItems:(UIViewController *)targetViewController {
    self.navigationItem.leftBarButtonItem = targetViewController.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = targetViewController.navigationItem.rightBarButtonItem;
}

@end
