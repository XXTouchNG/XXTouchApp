//
//  NSString+CountSubstr.m
//  XXTouchApp
//
//  Created by Zheng on 17/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSString+CountSubstr.h"

@implementation NSString (CountSubstr)

- (NSUInteger)occurenceOfString:(NSString *)substring {
    const char *substr = [substring cStringUsingEncoding:NSUTF8StringEncoding];
    const char *selfstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned long substrlen = strlen(substr);
    NSUInteger count = 0;
    char * ptr = (char *)selfstr;
    while ((ptr = strstr(ptr, substr)) != NULL && substr != '\0') {
        count++;
        ptr += substrlen;
    }
    return count;
}

@end
