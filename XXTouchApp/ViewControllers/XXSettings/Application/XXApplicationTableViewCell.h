//
//  XXApplicationTableViewCell.h
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXApplicationKeyBundleID = @"bid";
static NSString * const kXXApplicationKeyAppName = @"name";
static NSString * const kXXApplicationKeyBundlePath = @"bundle_path";
static NSString * const kXXApplicationKeyDataPath = @"data_path";
static NSString * const kXXApplicationKeyIcon = @"icon";

@interface XXApplicationTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *appInfo;

@end
