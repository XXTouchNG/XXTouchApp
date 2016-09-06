//
//  XXQuickLookService.h
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>

@interface XXQuickLookService : NSObject
+ (id)sharedInstance;

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)selectableFileExtensions;
+ (BOOL)isSelectableFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)editableFileExtensions;
+ (BOOL)isEditableFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)viewableFileExtensions;
+ (BOOL)isViewableFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)imageFileExtensions;
+ (NSArray <NSString *> *)mediaFileExtensions;
+ (NSArray <NSString *> *)audioFileExtensions;
+ (NSArray <NSString *> *)videoFileExtensions;
+ (NSArray <NSString *> *)archiveFileExtensions;
+ (NSArray <NSString *> *)webViewFileExtensions;
+ (NSArray <NSString *> *)supportedArchiveFileExtensions;
+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
+ (void)archiveItems:(NSArray <NSString *> *)items
parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
@end
