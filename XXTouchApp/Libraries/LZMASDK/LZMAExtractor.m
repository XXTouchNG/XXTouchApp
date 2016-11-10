//
//  LZMAExtractor.m
//  flipbooks
//
//  Created by Mo DeJong on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LZMAExtractor.h"

int do7z_extract_entry(char *archivePath, char *archiveCachePath, char *entryName, char *entryPath, int fullPaths);

@implementation LZMAExtractor

// Return a fully qualified random filename in the tmp dir. The filename is based on the
// exact time offset since 1970 so it should be unique.

+ (NSString*) generateUniqueTmpCachePath
{
    NSString *tmpDir = NSTemporaryDirectory();
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval ti = [nowDate timeIntervalSinceReferenceDate];
    
    // Format number of seconds as a string with a decimal separator
    NSString *doubleString = [NSString stringWithFormat:@"%f", ti];
    
    // Remove the decimal point so that the file name consists of
    // numeric characters only.
    
    NSRange range;
    range = NSMakeRange(0, [doubleString length]);
    NSString *noDecimalString = [doubleString stringByReplacingOccurrencesOfString:@"."
                                                                        withString:@""
                                                                           options:0
                                                                             range:range];
    
    range = NSMakeRange(0, [noDecimalString length]);
    NSString *noMinusString = [noDecimalString stringByReplacingOccurrencesOfString:@"-"
                                                                         withString:@""
                                                                            options:0
                                                                              range:range];
    
    NSString *filename = [NSString stringWithFormat:@"%@%@", noMinusString, @".cache"];
    
    NSString *tmpPath = [tmpDir stringByAppendingPathComponent:filename];
    
    return tmpPath;
}

+ (BOOL) extract7zArchive:(NSString *)archivePath
                  dirName:(NSString *)dirName
              preserveDir:(BOOL)preserveDir
                    error:(NSError **)error
{
    if (archivePath == nil || dirName == nil) {
        return NO;
    }
    BOOL worked, isDir, existsAlready;
    
    NSString *myTmpDir = dirName;
    existsAlready = [[NSFileManager defaultManager] fileExistsAtPath:myTmpDir isDirectory:&isDir];
    
    if (existsAlready && !isDir) {
        worked = [[NSFileManager defaultManager] removeItemAtPath:myTmpDir error:error];
        if (!worked) return NO;
    }
    
    if (existsAlready && isDir) {
        // Remove all the files in the named tmp dir
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:myTmpDir error:error];
        if (!contents) return NO;
        for (NSString *path in contents) {
            NSString *myTmpDirPath = [myTmpDir stringByAppendingPathComponent:path];
            worked = [[NSFileManager defaultManager] removeItemAtPath:myTmpDirPath error:error];
            if (!worked) return NO;
        }
    } else {
        worked = [[NSFileManager defaultManager] createDirectoryAtPath:myTmpDir withIntermediateDirectories:YES attributes:nil error:error];
        if (!worked) return NO;
    }
    
    worked = [[NSFileManager defaultManager] changeCurrentDirectoryPath:myTmpDir];
    if (!worked) return NO;
    
    char *archivePathPtr = (char *) [archivePath UTF8String];
    NSString *archiveCachePath = [self generateUniqueTmpCachePath];
    char *archiveCachePathPtr = (char *) [archiveCachePath UTF8String];
    char *entryNamePtr = NULL; // Extract all entries by passing NULL
    char *entryPathPtr = NULL;
    
    int result = do7z_extract_entry(archivePathPtr, archiveCachePathPtr, entryNamePtr, entryPathPtr, preserveDir ? 1 : 0);
    if (result != 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to open archive file", nil)};
        if (error) {
            *error = [NSError errorWithDomain:@"LZMAExtractorErrorDomain" code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    return YES;
}

@end
