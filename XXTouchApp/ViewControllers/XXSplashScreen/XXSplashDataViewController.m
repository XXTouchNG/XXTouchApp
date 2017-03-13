//
//  XXSplashDataViewController.m
//  ExampleCurl
//
//  Created by Zheng on 12/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXSplashDataViewController.h"

@interface XXSplashDataViewController ()

@end

@implementation XXSplashDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}


@end
