//
//  XXQuickLookService.m
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXQuickLookService.h"
#import "NSArray+FindString.h"

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

@end
