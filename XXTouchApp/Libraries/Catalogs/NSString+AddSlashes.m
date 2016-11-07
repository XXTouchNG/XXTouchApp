//
//  NSString+AddSlashes.m
//  XXTouchApp
//
//  Created by Zheng on 9/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSString+AddSlashes.h"

@implementation NSString (AddSlashes)

- (NSString *)addSlashes {
    NSString *newString = [self mutableCopy];
    newString = [newString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    newString = [newString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    return newString;
}

@end
