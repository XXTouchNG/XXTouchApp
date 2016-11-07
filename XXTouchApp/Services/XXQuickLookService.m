//
//  XXQuickLookService.m
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Photos/PHPhotoLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVPlayer.h>
#import <AVKit/AVPlayerViewController.h>
#import "XXQuickLookService.h"
#import "XXLocalDataService.h"
#import "XXArchiveService.h"
#import "JTSImageViewController.h"
#import "XXEmptyNavigationController.h"
#import "XXWebViewController.h"
#import "XXBaseTextEditorViewController.h"
#import "NSArray+FindString.h"

static NSString * const kXXNavigationControllerStoryboardID = @"kXXNavigationControllerStoryboardID";

@implementation XXQuickLookService

#pragma mark - Resources

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
    else if ([[XXArchiveService supportedFileType] existsString:fileExt])
    {
        fetchResult = [UIImage imageNamed:@"file-archive"];
    }
    else
    {
        fetchResult = [UIImage imageNamed:@"file-unknown"];
    }
    return fetchResult;
}

+ (UIImage *)fetchDisplayImageForSpecialItem:(NSString *)value {
    UIImage *fetchResult = [UIImage imageNamed:[@"special-" stringByAppendingString:value]];
    if (fetchResult != nil) {
        return fetchResult;
    }
    return [UIImage imageNamed:@"file-unknown"];
}

#pragma mark - Definitions

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

#pragma mark - Common Viewers

+ (NSArray <NSString *> *)imageFileExtensions
{ // OK
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
}

+ (NSArray <NSString *> *)mediaFileExtensions
{ // OK
    return @[ @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi" ];
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
    return [XXWebViewController supportedFileType];
}

+ (NSArray <NSString *> *)archiveFileExtensions
{ // OK
    return [XXArchiveService supportedFileType];
}

+ (NSArray <NSString *> *)textEditorFileExtensions
{ // OK
    return [XXBaseTextEditorViewController supportedFileType];
}

#pragma mark - Judgements

+ (BOOL)isSelectableFileExtension:(NSString *)ext {
    NSString *fileExt = [ext lowercaseString];
    return [[self selectableFileExtensions] existsString:fileExt];
}

#pragma mark - Viewers

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[self imageFileExtensions] existsString:fileExt])
    { // Image File
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL fileURLWithPath:filePath];
        JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                                   mode:JTSImageViewControllerMode_Image
                                                                                        backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewController.interactionsDelegate = [XXLocalDataService sharedInstance];
        [imageViewController showFromViewController:viewController.navigationController
                                         transition:JTSImageViewControllerTransition_FromOffscreen];
        return YES;
    } else if ([[self mediaFileExtensions] existsString:fileExt])
    { // Media File
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            // 7.x
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:sourceMovieURL];
            [viewController.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer]; // Its animation is different from AVPlayerViewController
        } else {
            // 8.0+
            AVPlayer *player = [[AVPlayer alloc] initWithURL:sourceMovieURL];
            AVPlayerViewController *moviePlayer = [[AVPlayerViewController alloc] init];
            moviePlayer.player = player;
            [viewController.navigationController presentViewController:moviePlayer animated:YES completion:nil];
        }
        return YES;
    }
    else
        if ([[XXWebViewController supportedFileType] existsString:fileExt])
    { // Web View File
        XXEmptyNavigationController *navController = [viewController.storyboard instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
        XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
        webController.url = [NSURL fileURLWithPath:filePath];
        webController.title = [filePath lastPathComponent];
        [viewController.navigationController presentViewController:navController animated:YES completion:nil];
        return YES;
    }
    else
    { // Not supported
        
    }
    return NO;
}

#pragma mark - Editors

+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[XXBaseTextEditorViewController supportedFileType] existsString:fileExt])
    { // Text Editor
        XXBaseTextEditorViewController *baseController = [[XXBaseTextEditorViewController alloc] init];
        baseController.filePath = filePath;
        baseController.title = [filePath lastPathComponent];
        [viewController.navigationController pushViewController:baseController animated:YES];
        return YES;
    }
    else
    { // Not supported
    
    }
    return NO;
}

@end
