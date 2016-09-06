//
//  NSFileManager+RealDestination.m
//  XXTouchApp
//
//  Created by Zheng on 9/3/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSFileManager+realDestination.h"

@implementation NSFileManager (RealDestination)

- (NSString *)realDestinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error {
    NSError *err = nil;
    NSString *destPath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:path error:&err];
    if (err) {
        *error = err;
        return nil;
    }
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:destPath error:&err];
    if (err) {
        *error = err;
        return nil;
    }
    if ([attrs objectForKey:NSFileType] == NSFileTypeSymbolicLink) {
        return [self realDestinationOfSymbolicLinkAtPath:destPath error:&err];
    }
    return destPath;
}

@end
