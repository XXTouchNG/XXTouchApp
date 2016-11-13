//
//  XXTextActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXTextActivity.h"
#import "XXBaseTextEditorViewController.h"

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

- (void)presentActivity
{
    [super presentActivity];
    UIViewController *viewController = self.baseController;
    XXBaseTextEditorViewController *baseController = [[XXBaseTextEditorViewController alloc] init];
    baseController.filePath = [self.fileURL path];
    baseController.title = [self.fileURL lastPathComponent];
    [viewController.navigationController pushViewController:baseController animated:YES];
}

@end
