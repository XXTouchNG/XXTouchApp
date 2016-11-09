//
//  XXImageActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImageActivity.h"
#import "JTSImageViewController.h"
#import "XXLocalDataService.h"

@implementation XXImageActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-image";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Open as Image", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-image"];
}

- (void)performActivity
{
    UIViewController *viewController = self.baseController;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = self.fileURL;
    JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                               mode:JTSImageViewControllerMode_Image
                                                                                    backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    imageViewController.interactionsDelegate = [XXLocalDataService sharedInstance];
    [imageViewController showFromViewController:viewController.navigationController
                                     transition:JTSImageViewControllerTransition_FromOffscreen];
    [self activityDidFinish:YES];
}

@end
