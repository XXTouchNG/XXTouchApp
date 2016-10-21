//
//  XXCodeBlockExpandViewController.h
//  XXTouchApp
//
//  Created by Zheng on 21/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXCodeBlockExpandViewControllerStoryboardID = @"kXXCodeBlockExpandViewControllerStoryboardID";

@interface XXCodeBlockExpandViewController : UIViewController
@property (nonatomic, copy) NSString *injectedCode;

@end
