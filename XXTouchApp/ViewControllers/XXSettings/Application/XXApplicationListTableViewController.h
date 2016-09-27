//
//  XXApplicationListTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

static NSString * const kXXApplicationListTableViewControllerStoryboardID = @"kXXApplicationListTableViewControllerStoryboardID";

@interface XXApplicationListTableViewController : UITableViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@end
