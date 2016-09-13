//
//  XXNavigationViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXNavigationViewController.h"
#import "XXLocalNetService.h"

static NSString * const tmpLockedItemPath = @"/private/var/tmp/1ferver_need_respring";

@interface XXNavigationViewController ()

@end

@implementation XXNavigationViewController

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if ([FCFileManager existsItemAtPath:tmpLockedItemPath]) {
        self.view.userInteractionEnabled = NO;
        @weakify(self);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Needs Respring") andMessage:XXLString(@"You should resping your device to continue to use this application.")];
        [alertView addButtonWithTitle:XXLString(@"Respring Now") type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            @strongify(self);
            [self.view makeToastActivity:CSToastPositionCenter];
            [XXLocalNetService killBackboardd];
        }];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
