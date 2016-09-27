//
//  XXCodeBlockModel.h
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kXXCodeBlockTypeInternalFunction = 0,
    kXXCodeBlockTypeUserDefined = 1,
} kXXCodeBlockType;

@interface XXCodeBlockModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) kXXCodeBlockType type;

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code;
+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code type:(kXXCodeBlockType)type;
@end
