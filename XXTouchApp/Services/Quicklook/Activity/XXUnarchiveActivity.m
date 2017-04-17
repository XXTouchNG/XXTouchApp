//
//  XXUnarchiveActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXUnarchiveActivity.h"
#import <SSZipArchive/SSZipArchive.h>

@implementation XXUnarchiveActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"zip" ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-unarchive";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Extract as Archive", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-unarchive"];
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    
    UINavigationController *navController = controller.navigationController;
    NSString *filePath = [self.fileURL path];
    NSString *fileName = [self.fileURL lastPathComponent];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Unarchive", nil)
                                                     andMessage:NSLocalizedString(@"Extract to the current directory?", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        NSString *fileNameNoExt = [fileName stringByDeletingPathExtension];
        NSString *fileExt = [[fileName pathExtension] lowercaseString];
        NSString *destinationRootPath = [filePath stringByDeletingLastPathComponent];
        NSString *destination = [destinationRootPath stringByAppendingPathComponent:fileNameNoExt];
        if ([[NSFileManager defaultManager] fileExistsAtPath:destination]) {
            NSUInteger testIndex = 2;
            do {
                destination = [destinationRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%lu", fileNameNoExt, (unsigned long)testIndex]];
                testIndex++;
            } while ([[NSFileManager defaultManager] fileExistsAtPath:destination]);
        }
        
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [navController.view makeToast:[error localizedDescription]];
        } else {
            navController.view.userInteractionEnabled = NO;
            [navController.view makeToastActivity:CSToastPositionCenter];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSError *err = nil;
                if ([fileExt isEqualToString:@"zip"])
                {
                    [SSZipArchive unzipFileAtPath:filePath
                                    toDestination:destination
                                        overwrite:YES
                                         password:nil
                                            error:&err
                                         delegate:nil];
                }
                dispatch_async_on_main_queue(^{
                    navController.view.userInteractionEnabled = YES;
                    [navController.view hideToastActivity];
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kXXGlobalNotificationList object:nil userInfo:@{kXXGlobalNotificationKeyEvent: kXXGlobalNotificationKeyEventUnarchive}]];
                    if (err) {
                        [navController.view makeToast:[error localizedDescription]];
                    } else {
                        [navController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
                    }
                });
            });
        }
    }];
    
    [alertView show];
    [self activityDidFinish:YES];
}

@end
