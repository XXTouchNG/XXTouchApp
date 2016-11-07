//
//  XXQuickLookService.h
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>

static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemRealPathKey = @"kXXItemRealPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";
static NSString * const kXXItemSymbolAttrsKey = @"kXXItemSymbolAttrsKey";
static NSString * const kXXItemSpecialKey = @"kXXItemSpecialKey";

static NSString * const kXXItemSpecialValueHome = @"kXXItemSpecialValueHome";

@interface XXQuickLookService : NSObject

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;
+ (UIImage *)fetchDisplayImageForSpecialItem:(NSString *)value;

+ (NSArray <NSString *> *)selectableFileExtensions;
+ (BOOL)isSelectableFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)imageFileExtensions;
+ (NSArray <NSString *> *)mediaFileExtensions;
+ (NSArray <NSString *> *)audioFileExtensions;
+ (NSArray <NSString *> *)videoFileExtensions;
+ (NSArray <NSString *> *)webViewFileExtensions;
+ (NSArray <NSString *> *)archiveFileExtensions;
+ (NSArray <NSString *> *)textEditorFileExtensions;

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController;
@end
