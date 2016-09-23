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

static NSString * const kXXNavigationControllerStoryboardID = @"kXXNavigationControllerStoryboardID";

@implementation XXQuickLookService

#pragma mark - Resources

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext {
    NSString *fileExt = [ext lowercaseString];
    UIImage *fetchResult = [UIImage imageNamed:[@"file-" stringByAppendingString:fileExt]];
    if (fetchResult != nil) {
        return fetchResult;
    }
    if ([[self imageFileExtensions] indexOfObject:fileExt] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-image"];
    } else if ([[self audioFileExtensions] indexOfObject:fileExt] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-audio"];
    } else if ([[self videoFileExtensions] indexOfObject:fileExt] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-video"];
    } else if ([[self archiveFileExtensions] indexOfObject:fileExt] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-archive"];
    } else {
        fetchResult = [UIImage imageNamed:@"file-unknown"];
    }
    return fetchResult;
}

#pragma mark - Definitions

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

+ (NSArray <NSString *> *)editableFileExtensions {
    return @[ @"lua", @"txt", @"log", // Text Editor
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
    return @[ @"lua", @"txt", @"log" ];
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
    return @[ @"txt", @"log", @"html", @"htm", @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", @"svg", @"epub" ];
}

#pragma mark - Archives

+ (NSArray <NSString *> *)archiveFileExtensions { // OK
    return @[ @"zip", @"bz2", @"tar", @"gz", @"rar" ];
}

#pragma mark - Judgements

+ (BOOL)isSelectableFileExtension:(NSString *)ext {
    return ([[self selectableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isEditableFileExtension:(NSString *)ext {
    return ([[self editableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isViewableFileExtension:(NSString *)ext {
    return ([[self viewableFileExtensions] indexOfObject:ext] != NSNotFound);
}

#pragma mark - Actions

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[self imageFileExtensions] indexOfObject:fileExt] != NSNotFound) { // Image File
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL fileURLWithPath:filePath];
        JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                                   mode:JTSImageViewControllerMode_Image
                                                                                        backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewController.interactionsDelegate = [XXLocalDataService sharedInstance];
        [imageViewController showFromViewController:viewController.navigationController
                                         transition:JTSImageViewControllerTransition_FromOffscreen];
        return YES;
    } else if ([[self mediaFileExtensions] indexOfObject:fileExt] != NSNotFound) { // Media File
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
    } else if ([[self webViewFileExtensions] indexOfObject:fileExt] != NSNotFound) { // Web View File
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
    if ([[self textFileExtensions] indexOfObject:fileExt] != NSNotFound) { // Text File
        XXBaseTextEditorViewController *baseController = [[XXBaseTextEditorViewController alloc] init];
        baseController.filePath = filePath;
        baseController.title = [filePath lastPathComponent];
        [viewController.navigationController pushViewController:baseController animated:YES];
        return YES;
    }
    return NO;
}

@end
