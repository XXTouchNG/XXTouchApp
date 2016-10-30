//
//  XXArchiveService.h
//  XXTouchApp
//
//  Created by Zheng on 9/7/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>
#import "XXFileViewer.h"

@interface XXArchiveService : NSObject <XXFileViewer>
+ (NSArray <NSString *> *)supportedArchiveFileExtensions;
+ (BOOL)unArchiveZip:(NSString *)filePath
         toDirectory:(NSString *)path
parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;
+ (BOOL)archiveItems:(NSArray <NSString *> *)items
         toDirectory:(NSString *)path
parentViewController:(UIViewController <SSZipArchiveDelegate> *)viewController;

@end
