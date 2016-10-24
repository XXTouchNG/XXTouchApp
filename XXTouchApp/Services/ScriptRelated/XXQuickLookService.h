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
+ (NSArray <NSString *> *)editableFileExtensions;
+ (BOOL)isEditableFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)viewableFileExtensions;
+ (BOOL)isViewableFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)textFileExtensions;
+ (NSArray <NSString *> *)imageFileExtensions;
+ (NSArray <NSString *> *)mediaFileExtensions;
+ (NSArray <NSString *> *)audioFileExtensions;
+ (NSArray <NSString *> *)videoFileExtensions;
+ (NSArray <NSString *> *)archiveFileExtensions;
+ (NSArray <NSString *> *)webViewFileExtensions;

+ (NSArray <NSString *> *)logWebViewFileExtensions;
+ (NSArray <NSString *> *)codeWebViewFileExtensions;

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController;
@end
