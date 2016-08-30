//
//  XXLocalCommandBaseRequest.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalCommandBaseRequest.h"

@implementation XXLocalCommandBaseRequest

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if (
        [propertyName isEqualToString:@"requestMethod"] ||
        [propertyName isEqualToString:@"requestUrl"] ||
        [propertyName isEqualToString:@"requestBody"]
        ) {
        return YES;
    }
    return NO;
}

- (NSString *)requestBody {
    return [self toJSONString];
}

@end
