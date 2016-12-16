//
//  XXQuickLookService.h
//  XXTouchApp
//
//  Created by Zheng on 9/5/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXScriptListTableViewController.h"

#import "XXWebActivity.h"
#import "XXImageActivity.h"
#import "XXMediaActivity.h"
#import "XXTextActivity.h"
#import "XXArchiveActivity.h"
#import "XXUnarchiveActivity.h"
#import "XXTerminalActivity.h"
#import "XXPaymentActivity.h"

static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemRealPathKey = @"kXXItemRealPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";
static NSString * const kXXItemSymbolAttrsKey = @"kXXItemSymbolAttrsKey";
static NSString * const kXXItemSpecialKey = @"kXXItemSpecialKey";
static NSString * const kXXItemSpecialValueHome = @"special-home";

@interface XXQuickLookService : NSObject
+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext;
+ (NSArray <NSString *> *)selectableFileExtensions;
@end
