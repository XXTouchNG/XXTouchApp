//
//  ALAssetsLibrary+SingleInstance.m
//  XXTouchApp
//
//  Created by Zheng on 9/6/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "ALAssetsLibrary+SingleInstance.h"

@implementation ALAssetsLibrary (SingleInstance)
+ (ALAssetsLibrary *)sharedLibrary {
    static dispatch_once_t onceToken;
    static ALAssetsLibrary *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[ALAssetsLibrary alloc] init];
    });
    return shared;
}

@end
