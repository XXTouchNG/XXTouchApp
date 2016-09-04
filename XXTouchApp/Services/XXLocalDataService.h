//
//  XXLocalDataService.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXLocalFileModel.h"

typedef enum : NSUInteger {
    kXXPasteboardTypeCopy,
    kXXPasteboardTypeCut,
} kXXPasteboardType;

@interface XXLocalDataService : NSObject
+ (id)sharedInstance;

@property (nonatomic, strong) NSArray <XXLocalFileModel *> *localFiles;
@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, copy) NSString *selectedScript;

- (BOOL)isSelectedScriptInPath:(NSString *)path;

@property (nonatomic, assign) kXXPasteboardType pasteboardType;
@property (nonatomic, strong) NSMutableArray <NSString *> *pasteboardArr;

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)selectableFileExtensions;
+ (BOOL)isSelectableFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)editableFileExtensions;
+ (BOOL)isEditableFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)viewableFileExtensions;
+ (BOOL)isViewableFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)imageFileExtensions;
+ (void)viewFileWithStandardViewer:(NSString *)filePath parentViewController:(UIViewController *)viewController;

@end
