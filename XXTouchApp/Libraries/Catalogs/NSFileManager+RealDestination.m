//
//  NSFileManager+RealDestination.m
//  XXTouchApp
//
//  Created by Zheng on 9/3/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSFileManager+RealDestination.h"

static NSFileManager *sharedManager = nil;

static inline NSFileManager *getSharedManager () {
    if (!sharedManager) {
        sharedManager = [[NSFileManager alloc] init];
    }
    return sharedManager;
}

@implementation NSFileManager (RealDestination)

- (NSString *)realDestinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error {
    NSError *err = nil;
    NSString *destPath = [getSharedManager() destinationOfSymbolicLinkAtPath:path error:&err];
    if (err) {
        *error = err;
        return nil;
    }
    NSDictionary *attrs = [getSharedManager() attributesOfItemAtPath:destPath error:&err];
    if (err) {
        *error = err;
        return nil;
    }
    if (attrs[NSFileType] == NSFileTypeSymbolicLink) {
        return [self realDestinationOfSymbolicLinkAtPath:destPath error:&err];
    }
    return destPath;
}

@end
