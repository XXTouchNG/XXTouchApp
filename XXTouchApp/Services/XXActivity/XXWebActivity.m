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

- (void)presentActivity {
    [super presentActivity];
    UIViewController *viewController = self.baseController;
    XXEmptyNavigationController *navController = [viewController.storyboard instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
    XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
    webController.url = self.fileURL;
    webController.title = [self.fileURL lastPathComponent];
    [viewController.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
