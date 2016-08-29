//
//  XXLocalCommandGetFileList.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalCommandGetFileList.h"

@implementation XXLocalCommandGetFileList

- (XXLocalCommandMethod)requestMethod {
    return kXXLocalCommandMethodPOST;
}

- (NSString *)requestUrl {
    return @"/get_file_list";
}

@end
