//
//  NSData+PlistData.m
//  XXTouchApp
//
//  Created by Zheng on 30/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NSData+plistData.h"

@implementation NSData (plistData)

- (NSString *)plistString {
    id plistData = [NSDictionary dictionaryWithPlistData:self];
    if (!plistData)
    {
        plistData = [NSArray arrayWithPlistData:self];
    }
    if (!plistData)
    {
        return nil;
    }
    if (
        [plistData isKindOfClass:[NSDictionary class]] ||
        [plistData isKindOfClass:[NSArray class]]
        ) {
        return [plistData plistString];
    }
    return nil;
}

@end
