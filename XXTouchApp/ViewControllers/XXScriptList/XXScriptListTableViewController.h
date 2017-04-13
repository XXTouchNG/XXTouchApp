//
//  XXScriptListTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XXScriptListTableViewControllerTypeNormal = 0,
    XXScriptListTableViewControllerTypeBootscript = 1,
    XXScriptListTableViewControllerTypePicker = 2,
} XXScriptListTableViewControllerType;

static NSString * const kXXScriptListTableViewControllerStoryboardID = @"kXXScriptListTableViewControllerStoryboardID";

@interface XXScriptListTableViewController : UIViewController
@property (nonatomic, assign) XXScriptListTableViewControllerType type;
@property (nonatomic, weak) UIViewController *selectViewController;
@property (nonatomic, copy) NSString *currentDirectory;

@end
