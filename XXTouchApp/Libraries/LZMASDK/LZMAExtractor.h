//
//  LZMAExtractor.h
//  lzmaSDK
//
//  Created by Brian Chaikelson on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZMAExtractor : NSObject
+ (BOOL) extract7zArchive:(NSString*)archivePath
                      dirName:(NSString*)dirName
                  preserveDir:(BOOL)preserveDir
                        error:(NSError **)error;

@end

