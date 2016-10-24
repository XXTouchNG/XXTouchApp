//
//  NSArray+FindString.m
//  XXTouchApp
//
//  Created by Zheng on 24/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSArray+FindString.h"

@implementation NSArray (FindString)

- (BOOL)existsString:(NSString *)str {
    for (NSString *s in self) {
        if ([s isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

@end
