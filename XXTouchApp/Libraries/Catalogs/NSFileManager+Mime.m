//
//  NSFileManager+Mime.m
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSFileManager+Mime.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSFileManager (Mime)

- (NSString *)mimeOfFiltAtPath:(NSString *)path {
    if (![self isReadableFileAtPath:path]) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    NSString *type = (__bridge NSString *)(MIMEType);
    CFRelease(MIMEType);
    return type;
}

@end
