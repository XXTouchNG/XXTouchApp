//
//  XXImageActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImageActivity.h"
#import "XXImageViewController.h"
#import "NSFileManager+Size.h"
#import "NSArray+FindString.h"

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

- (UIViewController *)activityViewController {
    NSString *path = [self.fileURL path];
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    NSArray <NSString *> *pathArray = [[NSFileManager defaultManager] listItemsInDirectoryAtPath:dirPath deep:NO cancelFlag:NULL];
    
    NSMutableArray <NSString *> *photosPath = [NSMutableArray new];
    [photosPath addObject:path];
    for (NSString *filePath in pathArray) {
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (exists &&
            !isDirectory &&
            ![path isEqualToString:filePath]) {
            NSString *fileExt = [[filePath pathExtension] lowercaseString];
            if ([[[self class] supportedExtensions] existsString:fileExt])
            {
                [photosPath addObject:filePath];
            }
        }
    }
    
    NSArray *photos = [IDMPhoto photosWithFilePaths:photosPath];
    XXImageViewController *browser = [[XXImageViewController alloc] initWithPhotos:photos];
    browser.activity = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    return browser;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    [controller.navigationController presentViewController:self.activityViewController animated:YES completion:nil];
}

@end
