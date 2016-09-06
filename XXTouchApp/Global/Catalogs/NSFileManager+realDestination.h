//
//  NSFileManager+RealDestination.h
//  XXTouchApp
//
//  Created by Zheng on 9/3/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (RealDestination)
- (NSString *)realDestinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error;

@end
