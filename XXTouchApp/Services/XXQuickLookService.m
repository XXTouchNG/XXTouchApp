//
//  XXQuickLookService.m
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXQuickLookService.h"
#import "JTSImageViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import "FYPhotoLibrary.h"

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
    UIImage *fetchResult = nil;
    if ([fileExt isEqualToString:@"lua"]) {
        fetchResult = [UIImage imageNamed:@"file-lua"];
    } else if ([fileExt isEqualToString:@"xxt"]) {
        fetchResult = [UIImage imageNamed:@"file-xxt"];
    } else if ([fileExt isEqualToString:@"txt"]) {
        fetchResult = [UIImage imageNamed:@"file-txt"];
    } else if ([[self imageFileExtensions] indexOfObject:fileExt] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-image"];
    } else {
        fetchResult = [UIImage imageNamed:@"file-unknown"];
    }
    return fetchResult;
}

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

+ (NSArray <NSString *> *)editableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"hex", @"dat", // Hex Editor
              ];
}

+ (NSArray <NSString *> *)viewableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"png", @"bmp", @"jpg", @"jpeg", @"gif", // Internal Image Viewer
              @"m4a", @"aac", @"m4v", @"m4r", @"mp3", // Internal Media Player
              @"html", @"htm", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", // Internal Web View
              @"zip", @"bz2", @"tar", @"gz", // Zip Extractor
              ];
}

+ (NSArray <NSString *> *)imageFileExtensions {
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
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
              parentViewController:(UIViewController *)viewController
{
    NSString *fileExt = [[filePath pathExtension] lowercaseString];
    if ([[self imageFileExtensions] indexOfObject:fileExt] != NSNotFound) { // Image File
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL fileURLWithPath:filePath];
        JTSImageViewController *imageViewController = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                                   mode:JTSImageViewControllerMode_Image
                                                                                        backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewController.interactionsDelegate = [self sharedInstance];
        [imageViewController showFromViewController:viewController transition:JTSImageViewControllerTransition_FromOffscreen];
        return YES;
    }
    return NO;
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // 7.x
        [[ALAssetsLibrary sharedLibrary] saveImage:imageViewer.image
                                           toAlbum:@"XXTouch"
                                        completion:^(NSURL *assetURL, NSError *error) {
                                            if (error == nil) {
                                                dispatch_async_on_main_queue(^{
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Image has been saved to the album.", @"XXTouch", nil)];
                                                });
                                            }
                                        } failure:^(NSError *error) {
                                            if (error != nil) {
                                                dispatch_async_on_main_queue(^{
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:[error localizedDescription]];
                                                });
                                            }
                                        }];
    } else {
        // 8.0+
        [[FYPhotoLibrary sharedInstance] requestLibraryAccessHandler:^(FYPhotoLibraryPermissionStatus statusResult) {
            if (statusResult == FYPhotoLibraryPermissionStatusDenied) {
                [imageViewer.view hideToastActivity];
                [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Failed to request photo library access.", @"XXTouch", nil)];
            } else if (statusResult == FYPhotoLibraryPermissionStatusGranted) {
                [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                                       toAlbum:@"XXTouch"
                                                    completion:^(BOOL success) {
                                                        if (success) {
                                                            dispatch_async_on_main_queue(^{
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:NSLocalizedStringFromTable(@"Image has been saved to the album.", @"XXTouch", nil)];
                                                            });
                                                        }
                                                    } failure:^(NSError * _Nullable error) {
                                                        if (error != nil) {
                                                            dispatch_async_on_main_queue(^{
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
