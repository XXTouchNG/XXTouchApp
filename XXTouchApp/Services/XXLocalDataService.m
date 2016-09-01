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

@end
