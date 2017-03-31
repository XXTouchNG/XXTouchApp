//
//  XXTextActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXTextActivity.h"
#import "XXBaseTextEditorViewController.h"
#import "XXEmptyNavigationController.h"

@implementation XXTextActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"lua", @"txt" ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-text";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Edit as Text", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"action-edit"];
}

- (UIViewController *)activityViewController
{
    XXBaseTextEditorViewController *baseController = [[XXBaseTextEditorViewController alloc] init];
    baseController.filePath = [self.fileURL path];
    baseController.title = [self.fileURL lastPathComponent];
    baseController.activity = self;
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:baseController];
    return navController;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
