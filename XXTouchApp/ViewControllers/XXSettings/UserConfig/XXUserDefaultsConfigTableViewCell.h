//
//  XXUserDefaultsConfigTableViewCell.h
//  XXTouchApp
//
//  Created by Zheng on 9/13/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXUserDefaultsConfigTitle = @"kXXUserDefaultsConfigTitle";
static NSString * const kXXUserDefaultsConfigDescription = @"kXXUserDefaultsConfigDescription";
static NSString * const kXXUserDefaultsConfigChoices = @"kXXUserDefaultsConfigChoices";
static NSString * const kXXUserDefaultsConfigKey = @"kXXUserDefaultsConfigKey";
static NSString * const kXXUserDefaultsConfigValue = @"kXXUserDefaultsConfigValue";

@interface XXUserDefaultsConfigTableViewCell : UITableViewCell
@property (nonatomic, strong) NSMutableDictionary *configInfo;

@end
