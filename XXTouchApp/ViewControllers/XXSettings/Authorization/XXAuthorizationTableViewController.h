//
//  XXAuthorizationTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/10/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXAuthorizationTableViewControllerStoryboardID = @"kXXAuthorizationTableViewControllerStoryboardID";

@interface XXAuthorizationTableViewController : UITableViewController
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) BOOL fromScan;

@end
