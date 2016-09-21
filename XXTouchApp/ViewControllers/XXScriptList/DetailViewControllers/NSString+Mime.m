//
//  NSString+Mime.m
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSString+Mime.h"
#import "FCFileManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSString (Mime)

- (NSString *)mime {
    if (![FCFileManager isReadableItemAtPath:self]) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    NSString *type = (__bridge NSString *)(MIMEType);
    CFRelease(MIMEType);
    return type;
}

- (NSUInteger)filesize {
    if (![FCFileManager isReadableItemAtPath:self]) {
        return 0;
    }
    
    return [[FCFileManager sizeOfFileAtPath:self] unsignedIntegerValue];
}

@end
