//
//  XXLocalDataService.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kXXPasteboardTypeCopy,
    kXXPasteboardTypeCut,
} kXXPasteboardType;

@interface XXLocalDataService : NSObject
+ (id)sharedInstance;

@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, copy) NSString *selectedScript;

- (BOOL)isSelectedScriptInPath:(NSString *)path;

@property (nonatomic, assign) kXXPasteboardType pasteboardType;
@property (nonatomic, strong) NSMutableArray <NSString *> *pasteboardArr;

@end
