//
//  XXQuickLookService.m
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Photos/PHPhotoLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVPlayerViewController.h>
#import "XXQuickLookService.h"
#import "JTSImageViewController.h"
#import "FYPhotoLibrary.h"
#import "XXNavigationController.h"
#import "XXWebViewController.h"

static NSString * const kXXNavigationControllerStoryboardID = @"kXXNavigationControllerStoryboardID";

@interface XXQuickLookService () <
    JTSImageViewControllerInteractionsDelegate
>

@end

@implementation XXQuickLookService
+ (id)sharedInstance {
    static XXQuickLookService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

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

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

+ (NSArray <NSString *> *)editableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", @"php", @"html", @"htm", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"hex", @"dat", // Hex Editor
              @"png", @"jpg", @"jpeg", // Image Editor
              ];
}

+ (NSArray <NSString *> *)viewableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", @"php", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              // Quick Look
              @"png", @"bmp", @"jpg", @"jpeg", @"gif", @"tif", @"tiff", // Internal Image Viewer
              @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi", // Internal Media Player
              @"html", @"htm", @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", @"svg", @"epub", // Internal Web View
              @"zip", @"bz2", @"tar", @"gz", @"rar", // Zip Extractor
              ];
}

+ (NSArray <NSString *> *)imageFileExtensions {
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
}

+ (NSArray <NSString *> *)mediaFileExtensions {
    return @[ @"m4a", @"aac", @"m4v", @"m4r", @"mp3", @"mov", @"mp4", @"ogg", @"aif", @"wav", @"flv", @"mpg", @"avi" ];
}

+ (NSArray <NSString *> *)audioFileExtensions {
    return @[ @"m4a", @"aac", @"m4r", @"mp3", @"ogg", @"aif", @"wav" ];
}

+ (NSArray <NSString *> *)videoFileExtensions {
    return @[ @"m4v", @"mov", @"mp4", @"flv", @"mpg", @"avi" ];
}

+ (NSArray <NSString *> *)archiveFileExtensions {
    return @[ @"zip", @"bz2", @"tar", @"gz", @"rar" ];
}

+ (NSArray <NSString *> *)webViewFileExtensions {
    return @[ @"html", @"htm", @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", @"svg", @"epub" ];
}

+ (BOOL)isSelectableFileExtension:(NSString *)ext {
    return ([[self selectableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isEditableFileExtension:(NSString *)ext {
    return ([[self editableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isViewableFileExtension:(NSString *)ext {
    return ([[self viewableFileExtensions] indexOfObject:ext] != NSNotFound);
}

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
        imageViewController.interactionsDelegate = [self sharedInstance];
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
        XXNavigationController *navController = [viewController.storyboard instantiateViewControllerWithIdentifier:kXXNavigationControllerStoryboardID];
        XXWebViewController *webController = (XXWebViewController *)navController.topViewController;
        webController.url = [NSURL fileURLWithPath:filePath];
        webController.title = [filePath lastPathComponent];
        [viewController.navigationController presentViewController:navController animated:YES completion:nil];
        return YES;
    }
    return NO;
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    imageViewer.view.userInteractionEnabled = NO;
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // 7.x
        [[ALAssetsLibrary sharedLibrary] saveImage:imageViewer.image
                                           toAlbum:@"XXTouch"
                                        completion:^(NSURL *assetURL, NSError *error) {
                                            if (error == nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Image has been saved to the album.", @"XXTouch", nil)];
                                                });
                                            }
                                        } failure:^(NSError *error) {
                                            if (error != nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:[error localizedDescription]];
                                                });
                                            }
                                        }];
    } else {
        // 8.0+
        [[FYPhotoLibrary sharedInstance] requestLibraryAccessHandler:^(FYPhotoLibraryPermissionStatus statusResult) {
            if (statusResult == FYPhotoLibraryPermissionStatusDenied) {
                imageViewer.view.userInteractionEnabled = YES;
                [imageViewer.view hideToastActivity];
                [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Failed to request photo library access.", @"XXTouch", nil)];
            } else if (statusResult == FYPhotoLibraryPermissionStatusGranted) {
                [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                                       toAlbum:@"XXTouch"
                                                    completion:^(BOOL success) {
                                                        if (success) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Image has been saved to the album.", @"XXTouch", nil)];
                                                            });
                                                        }
                                                    } failure:^(NSError * _Nullable error) {
                                                        if (error != nil) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:[error localizedDescription]];
                                                            });
                                                        }
                                                    }];
            }
        }];
    }
}

@end
