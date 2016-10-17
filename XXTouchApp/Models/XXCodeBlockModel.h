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

@interface XXCodeBlockModel : NSObject <NSCopying, NSMutableCopying, NSCoding>
@property (nonatomic, assign) NSUInteger currentStep;
@property (nonatomic, assign) NSUInteger totalStep;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *code;

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code;
+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code type:(kXXCodeBlockType)type;
@end
