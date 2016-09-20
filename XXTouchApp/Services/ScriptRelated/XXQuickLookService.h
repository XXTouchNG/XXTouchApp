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

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;

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

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController;
@end
