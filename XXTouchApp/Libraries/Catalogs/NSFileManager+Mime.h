//
//  NSFileManager+Mime.h
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Mime)
- (NSString *)mimeOfFiltAtPath:(NSString *)path;

@end
