//
//  NSString+Regexp.m
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSString+Regexp.h"

@implementation NSString (Regexp)
- (BOOL)validateWithRegExp:(NSString *)regExp {
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
    return [predicate evaluateWithObject:self];
}
@end
