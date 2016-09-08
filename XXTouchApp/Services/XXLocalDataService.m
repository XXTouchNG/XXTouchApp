//
//  XXLocalDataService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDataService.h"
#import "JTSImageViewController.h"

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
    if (selectedScript) {
        CYLog(@"%@", selectedScript);
    }
}

- (BOOL)isSelectedScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [_selectedScript hasPrefix:path];
}

@end
