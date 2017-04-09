//
//  XXWebActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXWebActivity.h"
#import "XXEmptyNavigationController.h"
#import "XXWebViewController.h"

@interface XXWebActivity ()

@end

@implementation XXWebActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return [XXWebViewController supportedFileType];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-web";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Open as Document", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-document"];
}

- (UIViewController *)activityViewController
{
    XXEmptyNavigationController *navController = [[UIStoryboard storyboardWithName:[XXEmptyNavigationController className] bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
    XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
    webController.url = self.fileURL;
    webController.title = [self.fileURL lastPathComponent];
    webController.activity = self;
    return navController;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
