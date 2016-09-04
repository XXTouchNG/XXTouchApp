//
//  XXLocalDataService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDataService.h"

@implementation XXLocalDataService
+ (id)sharedInstance {
    static XXLocalDataService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // Init Local Data Configure
        // Get Selected Script
    }
    return self;
}

- (NSString *)rootPath {
    if (!_rootPath) {
        _rootPath = [[UIApplication sharedApplication] documentsPath];
    }
    return _rootPath;
}

- (NSString *)libraryPath {
    if (!_libraryPath) {
        _libraryPath = [[UIApplication sharedApplication] libraryPath];
    }
    return _libraryPath;
}

- (NSDateFormatter *)defaultDateFormatter {
    if (!_defaultDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _defaultDateFormatter = dateFormatter;
    }
    return _defaultDateFormatter;
}

- (NSMutableArray <NSString *> *)pasteboardArr {
    if (!_pasteboardArr) {
        _pasteboardArr = [[NSMutableArray alloc] init];
    }
    return _pasteboardArr;
}

- (void)setSelectedScript:(NSString *)selectedScript {
    _selectedScript = selectedScript;
    CYLog(@"%@", selectedScript);
}

- (BOOL)isSelectedScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [_selectedScript hasPrefix:path];
}

+ (UIImage *)fetchDisplayImageForFileExtension:(NSString *)ext {
    UIImage *fetchResult = nil;
    if ([ext isEqualToString:@"lua"]) {
        fetchResult = [UIImage imageNamed:@"file-lua"];
    } else if ([ext isEqualToString:@"xxt"]) {
        fetchResult = [UIImage imageNamed:@"file-xxt"];
    } else if ([ext isEqualToString:@"txt"]) {
        fetchResult = [UIImage imageNamed:@"file-txt"];
    } else if ([[self imageFileExtensions] indexOfObject:ext] != NSNotFound) {
        fetchResult = [UIImage imageNamed:@"file-image"];
    } else {
        fetchResult = [UIImage imageNamed:@"file-unknown"];
    }
    return fetchResult;
}

+ (NSArray <NSString *> *)selectableFileExtensions {
    return @[ @"xxt", @"lua" ];
}

+ (NSArray <NSString *> *)editableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"hex", @"dat", // Hex Editor
              ];
}

+ (NSArray <NSString *> *)viewableFileExtensions {
    return @[ @"lua", @"txt", @"xml", @"css", @"log", @"json", @"js", @"sql", // Text Editor
              @"db", @"sqlite", @"sqlitedb", // SQLite 3 Editor
              @"plist", @"strings", // Plist Editor
              @"png", @"bmp", @"jpg", @"jpeg", @"gif", // Internal Image Viewer
              @"m4a", @"aac", @"m4v", @"m4r", @"mp3", // Internal Media Player
              @"html", @"htm", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx", @"pages", @"key", @"numbers", // Internal Web View
              @"zip", @"bz2", @"tar", @"gz", // Zip Extractor
              ];
}

+ (NSArray <NSString *> *)imageFileExtensions {
    return @[ @"png", @"bmp", @"jpg", @"jpeg", @"gif" ];
}

+ (BOOL)isSelectableFileExtension:(NSString *)ext {
    return ([[self selectableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isEditableFileExtension:(NSString *)ext {
    return ([[self editableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (BOOL)isViewableFileExtension:(NSString *)ext {
    return ([[self viewableFileExtensions] indexOfObject:ext] != NSNotFound);
}

+ (void)viewFileWithStandardViewer:(NSString *)filePath parentViewController:(UIViewController *)viewController {
    
}

@end
