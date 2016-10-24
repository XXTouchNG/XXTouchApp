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
    if (fetchResult != nil) {
        return fetchResult;
    }
    if ([[self imageFileExtensions] existsString:fileExt]) {
        fetchResult = [UIImage imageNamed:@"file-image"];
    } else if ([[self audioFileExtensions] existsString:fileExt]) {
        fetchResult = [UIImage imageNamed:@"file-audio"];
    } else if ([[self videoFileExtensions] existsString:fileExt]) {
        fetchResult = [UIImage imageNamed:@"file-video"];
    } else if ([[self archiveFileExtensions] existsString:fileExt]) {
        fetchResult = [UIImage imageNamed:@"file-archive"];
    } else {
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

+ (NSArray <NSString *> *)editableFileExtensions {
    return @[ @"lua", @"txt", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"hex", @"dat", // Hex Editor
              ];
}

+ (NSArray <NSString *> *)viewableFileExtensions {
    return @[
             @"png", @"bmp", @"jpg", @"jpeg", @"gif", @"tif", @"tiff", // Internal Image Viewer
             @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi", // Internal Media Player
             @"html", @"htm", @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", @"svg", @"epub", // Internal Web View
             @"zip", @"bz2", @"tar", @"gz", @"rar", // Zip Extractor
             ];
}

#pragma mark - Editors

+ (NSArray <NSString *> *)textFileExtensions { // OK
    return @[ @"lua", @"txt" ];
}

#pragma mark - Viewers

+ (NSArray <NSString *> *)imageFileExtensions { // OK
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
}

+ (NSArray <NSString *> *)mediaFileExtensions { // OK
    return @[ @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi" ];
}

+ (NSArray <NSString *> *)audioFileExtensions { // OK
    return @[ @"m4a", @"aac", @"m4r", @"mp3", @"ogg", @"aif", @"wav" ];
}

+ (NSArray <NSString *> *)videoFileExtensions { // OK
    return @[ @"m4v", @"mov", @"mp4", @"flv", @"mpg", @"avi" ];
}

+ (NSArray <NSString *> *)webViewFileExtensions { // OK
    return @[ @"txt", @"log", @"syslog", @"ips", @"html", @"htm", @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", @"svg", @"epub" ];
}

+ (NSArray <NSString *> *)logWebViewFileExtensions { // Treat like plain text
    return @[ @"log", @"syslog", @"ips" ];
}

+ (NSArray <NSString *> *)codeWebViewFileExtensions { // Syntax highlighter
    return @[ ];
}

#pragma mark - Archives

+ (NSArray <NSString *> *)archiveFileExtensions { // OK
    return @[ @"zip", @"bz2", @"tar", @"gz", @"rar" ];
}

#pragma mark - Judgements

+ (BOOL)isSelectableFileExtension:(NSString *)ext {
    NSString *fileExt = [ext lowercaseString];
    return [[self selectableFileExtensions] existsString:fileExt];
}

+ (BOOL)isEditableFileExtension:(NSString *)ext {
    NSString *fileExt = [ext lowercaseString];
    return [[self editableFileExtensions] existsString:fileExt];
}

+ (BOOL)isViewableFileExtension:(NSString *)ext {
    NSString *fileExt = [ext lowercaseString];
    return [[self viewableFileExtensions] existsString:fileExt];
}

#pragma mark - Actions

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[self imageFileExtensions] existsString:fileExt]) { // Image File
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL fileURLWithPath:filePath];
        JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                                   mode:JTSImageViewControllerMode_Image
                                                                                        backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewController.interactionsDelegate = [XXLocalDataService sharedInstance];
        [imageViewController showFromViewController:viewController.navigationController
                                         transition:JTSImageViewControllerTransition_FromOffscreen];
        return YES;
    } else if ([[self mediaFileExtensions] existsString:fileExt]) { // Media File
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
            [viewController.navigationController presentViewController:moviePlayer animated:YES completion:^() {
                [player play];
            }];
        }
        return YES;
    } else if ([[self webViewFileExtensions] existsString:fileExt]) { // Web View File
        XXEmptyNavigationController *navController = [viewController.storyboard instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
        XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
        webController.url = [NSURL fileURLWithPath:filePath];
        webController.title = [filePath lastPathComponent];
        [viewController.navigationController presentViewController:navController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController {
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[self textFileExtensions] existsString:fileExt]) { // Text File
        XXBaseTextEditorViewController *baseController = [[XXBaseTextEditorViewController alloc] init];
        baseController.filePath = filePath;
        baseController.title = [filePath lastPathComponent];
        [viewController.navigationController pushViewController:baseController animated:YES];
        return YES;
    }
    return NO;
}

@end
