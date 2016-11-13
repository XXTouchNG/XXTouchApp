//
//  XXPaymentActivity.m
//  XXTouchApp
//
//  Created by Zheng on 13/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPaymentActivity.h"
#import "XXEmptyNavigationController.h"
#import "XXPaymentViewController.h"

@implementation XXPaymentActivity

- (void)presentActivity {
    [super presentActivity];
    UIViewController *viewController = self.baseController;
    XXPaymentViewController *paymentController = [[XXPaymentViewController alloc] init];
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:paymentController];
    [viewController.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
