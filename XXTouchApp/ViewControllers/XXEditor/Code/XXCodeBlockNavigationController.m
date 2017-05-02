//
//  XXCodeBlockNavigationController.m
//  XXTouchApp
//
//  Created by Zheng on 13/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockNavigationController.h"

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

@end
