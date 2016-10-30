//
//  XXFileViewer.h
//  XXTouchApp
//
//  Created by Zheng on 30/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XXFileViewer <NSObject>
+ (NSArray <NSString *> *)supportedFileType;

@end
