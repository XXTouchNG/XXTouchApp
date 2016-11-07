//
//  XXArchiveService.m
//  XXTouchApp
//
//  Created by Zheng on 9/7/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXArchiveService.h"
#import "NSArray+FindString.h"

@implementation XXArchiveService
+ (NSArray <NSString *> *)supportedArchiveFileExtensions {
    return @[ @"zip" ];
}

+ (NSArray <NSString *> *)supportedFileType {
    return @[ @"zip", @"bz2", @"tar", @"gz", @"rar" ];
}

+ (BOOL)unArchiveZip:(NSString *)filePath
         toDirectory:(NSString *)path
parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController {
    NSString *fileExt = [filePath pathExtension];
    if ([[self supportedArchiveFileExtensions] existsString:fileExt]) { // Zip Archive
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Unarchive", nil)
                                                         andMessage:NSLocalizedString(@"Extract to the current directory?\nItem with the same name will be overwritten.", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            __block UINavigationController *navController = viewController.navigationController;
            __block NSError *error = nil;
            __block NSString *destination = path;
            [FCFileManager createDirectoriesForPath:destination error:&error];
            if (error) {
                [navController.view makeToast:[error localizedDescription]];
            } else {
                navController.view.userInteractionEnabled = NO;
                [navController.view makeToastActivity:CSToastPositionCenter];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [SSZipArchive unzipFileAtPath:filePath
                                    toDestination:destination
                                        overwrite:YES
                                         password:nil
                                            error:&error
                                         delegate:viewController];
                    dispatch_async_on_main_queue(^{
                        navController.view.userInteractionEnabled = YES;
                        [navController.view hideToastActivity];
                        if (error) {
                            [navController.view makeToast:[error localizedDescription]];
                        } else {
                            [navController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
                        }
                    });
                });
            }
        }];
        [alertView show];
        return YES;
    }
    return NO;
}

+ (BOOL)archiveItems:(NSArray <NSString *> *)items
         toDirectory:(NSString *)path
parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController {
    if (items.count <= 0) {
        return NO;
    }
    
    __block UINavigationController *navController = viewController.navigationController;
    navController.view.userInteractionEnabled = NO;
    [navController.view makeToastActivity:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *destination = path;
        NSString *archiveName = nil;
        NSString *archivePath = nil;
        if (items.count == 1) {
            archiveName = [items[0] lastPathComponent];
        } else {
            archiveName = @"Archive";
        }
        NSString *archiveFullname = [archiveName stringByAppendingPathExtension:@"zip"];
        if ([FCFileManager existsItemAtPath:[destination stringByAppendingPathComponent:archiveFullname]]) {
            NSUInteger testIndex = 2;
            do {
                archivePath = [destination stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%lu.zip", archiveName, (unsigned long)testIndex]];
                testIndex++;
            } while ([FCFileManager existsItemAtPath:archivePath]);
        } else {
            archivePath = [destination stringByAppendingPathComponent:archiveFullname];
        }
        CYLog(@"%@", archivePath);
        BOOL result = [SSZipArchive createZipFileAtPath:archivePath
                                    withContentsOfItems:items
                                    keepParentDirectory:NO
                                           withPassword:nil
                                               delegate:viewController];
        dispatch_async_on_main_queue(^{
            navController.view.userInteractionEnabled = YES;
            [navController.view hideToastActivity];
            if (!result) {
                [navController.view makeToast:NSLocalizedString(@"Cannot create zip file", nil)];
            } else {
                [navController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
            }
        });
    });
    return YES;
}

@end
