//
//  XXScriptListTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXScriptListTableViewControllerStoryboardID = @"kXXScriptListTableViewControllerStoryboardID";

@interface XXScriptListTableViewController : UIViewController
@property (nonatomic, assign) BOOL selectBootscript;
@property (nonatomic, weak) UIViewController *selectViewController;
@property (nonatomic, copy) NSString *currentDirectory;

@end
