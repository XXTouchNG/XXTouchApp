//
//  XXUserDefaultsModel.h
//  XXTouchApp
//
//  Created by Zheng on 9/14/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kXXUserDefaultsTypeSwitch = 0,
    kXXUserDefaultsTypeChoice,
} kXXUserDefaultsType;

@interface XXUserDefaultsModel : NSObject
@property (nonatomic, copy) NSString *configTitle;
@property (nonatomic, copy) NSString *configDescription;
@property (nonatomic, strong) NSArray <NSString *> *configChoices;
@property (nonatomic, assign) kXXUserDefaultsType configType;
@property (nonatomic, copy) NSString *configKey;
@property (nonatomic, assign) NSInteger configValue;
@property (nonatomic, assign) BOOL isRemote;

@end
