//
//  XXPaymentViewController.h
//  XXTouchApp
//
//  Created by Zheng on 13/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXBaseActivity.h"

@interface XXPaymentViewController : UIViewController
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, weak) XXBaseActivity *activity;

@end
