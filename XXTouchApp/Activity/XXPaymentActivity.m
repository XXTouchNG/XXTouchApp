//
//  XXPaymentActivity.m
//  XXTouchApp
//
//  Created by Zheng on 14/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXPaymentActivity.h"
#import "XXPaymentViewController.h"
#import "XXEmptyNavigationController.h"

@implementation XXPaymentActivity

- (NSString *)activityType
{
    return @"com.xxtouch.activity-payment";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Purchase", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-purchase"];
}

- (UIViewController *)activityViewController
{
    XXPaymentViewController *paymentController = [[XXPaymentViewController alloc] init];
    paymentController.activity = self;
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:paymentController];
    return navController;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
