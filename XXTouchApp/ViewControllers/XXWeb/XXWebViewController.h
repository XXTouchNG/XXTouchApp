//
//  XXWebViewController.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXBaseActivity.h"

typedef enum : NSUInteger {
    kXXWebViewLoadTypeCommon = 0,
    kXXWebViewLoadTypePlain  = 1,
    kXXWebViewLoadTypePlist  = 2,
    kXXWebViewLoadTypeCode   = 3,
} kXXWebViewLoadType;

@interface XXWebViewController : UIViewController
@property (nonatomic, weak) XXBaseActivity *activity;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) kXXWebViewLoadType loadType;

+ (NSArray <NSString *> *)supportedFileType;
@end
