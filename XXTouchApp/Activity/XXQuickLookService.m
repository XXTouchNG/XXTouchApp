//
//  XXQuickLookService.m
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXQuickLookService.h"
#import "XXLocalDataService.h"
#import "NSArray+FindString.h"

#import "XXWebActivity.h"
#import "XXImageActivity.h"
#import "XXMediaActivity.h"
#import "XXTextActivity.h"
#import "XXArchiveActivity.h"
#import "XXUnarchiveActivity.h"
#import "XXTerminalActivity.h"
#import "XXPaymentActivity.h"

@implementation XXQuickLookService

#pragma mark - Common Types

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext {
    if (!ext) return nil;
    NSString *fileExt = [ext lowercaseString];
    UIImage *fetchResult = [UIImage imageNamed:[@"file-" stringByAppendingString:fileExt]];
    if (fetchResult != nil)
    {
        return fetchResult;
    }
    if ([[self imageFileExtensions] existsString:fileExt])
    {
        fetchResult = [UIImage imageNamed:@"file-image"];
    }
    else if ([[self audioFileExtensions] existsString:fileExt])
    {
        fetchResult = [UIImage imageNamed:@"file-audio"];
    }
    else if ([[self videoFileExtensions] existsString:fileExt])
    {
        fetchResult = [UIImage imageNamed:@"file-video"];
    }
    else if ([[self archiveFileExtensions] existsString:fileExt])
    {
        fetchResult = [UIImage imageNamed:@"file-archive"];
    }
    else
    {
        fetchResult = [UIImage imageNamed:@"file-unknown"];
    }
    return fetchResult;
}

#pragma mark - Common Registers

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

+ (NSArray <NSString *> *)archiveFileExtensions {
    return @[ @"zip", @"bz2", @"tar", @"gz", @"rar", @"7z" ];
}

+ (NSArray <NSString *> *)imageFileExtensions
{ // OK
    return [XXImageActivity supportedExtensions];
}

+ (NSArray <NSString *> *)mediaFileExtensions
{ // OK
    return [XXMediaActivity supportedExtensions];
}

+ (NSArray <NSString *> *)audioFileExtensions
{ // OK
    return @[ @"m4a", @"aac", @"m4r", @"mp3", @"ogg", @"aif", @"wav" ];
}

+ (NSArray <NSString *> *)videoFileExtensions
{ // OK
    return @[ @"m4v", @"mov", @"mp4", @"flv", @"mpg", @"avi" ];
}

+ (NSArray <NSString *> *)webViewFileExtensions
{ // OK
    return [XXWebActivity supportedExtensions];
}

+ (NSArray <NSString *> *)textEditorFileExtensions
{ // OK
    return [XXTextActivity supportedExtensions];
}

#pragma mark - Type Viewers

+ (NSArray *)viewerActivities {
    if (daemonInstalled()) {
        return @[
                 [XXWebActivity class],
                 [XXImageActivity class],
                 [XXMediaActivity class],
                 [XXUnarchiveActivity class],
                 ];
    } else if ([[XXLocalDataService sharedInstance] purchasedProduct]) {
        return @[
                 [XXTerminalActivity class],
                 [XXWebActivity class],
                 [XXImageActivity class],
                 [XXMediaActivity class],
                 [XXUnarchiveActivity class],
                 ];
    } else {
        return @[
                 [XXPaymentActivity class],
                 [XXWebActivity class],
                 [XXImageActivity class],
                 [XXMediaActivity class],
                 [XXUnarchiveActivity class],
                 ];
    }
}

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    for (Class actClass in [self viewerActivities]) {
        if ([[actClass supportedExtensions] existsString:fileExt])
        {
            XXBaseActivity *act = [[actClass alloc] init];
            [act setFileURL:fileURL];
            [act performActivityWithController:viewController];
            return YES;
        }
    }
    { // Not supported
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:[self viewActivitiesWithViewController:viewController]];
        [controller setExcludedActivityTypes:@[ UIActivityTypeAirDrop ]];
        [viewController.navigationController presentViewController:controller animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (NSArray <UIActivity *> *)viewActivitiesWithViewController:(UIViewController *)controller {
    NSMutableArray *acts = [[NSMutableArray alloc] init];
    for (Class actClass in [self viewerActivities]) {
        XXBaseActivity *act = [[actClass alloc] init];
        act.baseController = controller;
        [acts addObject:act];
    }
    return [acts copy];
}

#pragma mark - Type Editors

+ (NSArray *)editorActivities {
    return @[
             [XXTextActivity class],
             ];
}

+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    for (Class actClass in [self editorActivities]) {
        if ([[actClass supportedExtensions] existsString:fileExt])
        {
            XXBaseActivity *act = [[actClass alloc] init];
            [act setFileURL:fileURL];
            [act performActivityWithController:viewController];
            return YES;
        }
    }
    { // Not supported
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:[self editActivitiesWithViewController:viewController]];
        [controller setExcludedActivityTypes:@[ UIActivityTypeAirDrop ]];
        [viewController.navigationController presentViewController:controller animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (NSArray <UIActivity *> *)editActivitiesWithViewController:(UIViewController *)controller {
    NSMutableArray *acts = [[NSMutableArray alloc] init];
    for (Class actClass in [self editorActivities]) {
        XXBaseActivity *act = [[actClass alloc] init];
        act.baseController = controller;
        [acts addObject:act];
    }
    return [acts copy];
}

@end
