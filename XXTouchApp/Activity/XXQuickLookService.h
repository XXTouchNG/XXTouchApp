//
//  XXQuickLookService.h
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemRealPathKey = @"kXXItemRealPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";
static NSString * const kXXItemSymbolAttrsKey = @"kXXItemSymbolAttrsKey";
static NSString * const kXXItemSpecialKey = @"kXXItemSpecialKey";
static NSString * const kXXItemSpecialValueHome = @"special-home";

@interface XXQuickLookService : NSObject

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;

+ (NSArray <NSString *> *)selectableFileExtensions;

+ (BOOL)viewFileWithStandardViewer:(NSString *)filePath
              parentViewController:(UIViewController *)viewController;
+ (BOOL)editFileWithStandardEditor:(NSString *)filePath
              parentViewController:(UIViewController *)viewController;
@end
