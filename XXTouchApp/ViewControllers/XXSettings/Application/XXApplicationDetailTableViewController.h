//
//  XXApplicationDetailTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSApplicationProxy.h"

static NSString * const kXXTMoreApplicationDetailKeyName = @"kXXTMoreApplicationDetailKeyName";
static NSString * const kXXTMoreApplicationDetailKeyBundleID = @"kXXTMoreApplicationDetailKeyBundleID";
static NSString * const kXXTMoreApplicationDetailKeyBundlePath = @"kXXTMoreApplicationDetailKeyBundlePath";
static NSString * const kXXTMoreApplicationDetailKeyContainerPath = @"kXXTMoreApplicationDetailKeyContainerPath";
static NSString * const kXXTMoreApplicationDetailKeyIconImage = @"kXXTMoreApplicationDetailKeyIconImage";

@interface XXApplicationDetailTableViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *applicationDetail;

@end
