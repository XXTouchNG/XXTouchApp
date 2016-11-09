//
//  XXUnarchiveActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXUnarchiveActivity.h"
#import <SSZipArchive/SSZipArchive.h>
#import "LZMAExtractor.h"

@implementation XXUnarchiveActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ @"zip", @"7z" ];
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

- (void)performActivity
{
    UIViewController *viewController = self.baseController;
    NSString *filePath = [self.fileURL path];
    NSString *fileName = [self.fileURL lastPathComponent];
    NSString *fileNameNoExt = [fileName stringByDeletingPathExtension];
    NSString *fileExt = [[fileName pathExtension] lowercaseString];
    NSString *destinationPath = [filePath stringByDeletingLastPathComponent];
    
    __block UINavigationController *navController = viewController.navigationController;
    __block NSError *error = nil;
    __block NSString *destination = [destinationPath stringByAppendingPathComponent:fileNameNoExt];
    
    if ([FCFileManager existsItemAtPath:destination]) {
        NSUInteger testIndex = 2;
        do {
            destination = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%lu", fileNameNoExt, (unsigned long)testIndex]];
            testIndex++;
        } while ([FCFileManager existsItemAtPath:destination]);
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Unarchive", nil)
                                                     andMessage:NSLocalizedString(@"Extract to the current directory?", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [FCFileManager createDirectoriesForPath:destination error:&error];
        if (error) {
            [navController.view makeToast:[error localizedDescription]];
        } else {
            navController.view.userInteractionEnabled = NO;
            [navController.view makeToastActivity:CSToastPositionCenter];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if ([fileExt isEqualToString:@"zip"])
                {
                    [SSZipArchive unzipFileAtPath:filePath
                                    toDestination:destination
                                        overwrite:YES
                                         password:nil
                                            error:&error
                                         delegate:nil];
                }
                else
                    if ([fileExt isEqualToString:@"7z"])
                {
                    [LZMAExtractor extract7zArchive:filePath
                                            dirName:destination
                                        preserveDir:YES
                                              error:&error];
                }
                
                dispatch_async_on_main_queue(^{
                    if (_delegate && [_delegate respondsToSelector:@selector(archiveDidUnArchiveAtPath:unzippedPath:)]) {
                        [_delegate archiveDidUnArchiveAtPath:filePath unzippedPath:destination];
                    }
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
    [self activityDidFinish:YES];
}

@end
