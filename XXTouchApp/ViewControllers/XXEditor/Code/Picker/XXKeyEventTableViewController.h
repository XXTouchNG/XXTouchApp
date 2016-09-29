//
//  XXKeyEventTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

static NSString * const kXXKeyEventTableViewControllerStoryboardID = @"kXXKeyEventTableViewControllerStoryboardID";

@interface XXKeyEventTableViewController : UITableViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@end
