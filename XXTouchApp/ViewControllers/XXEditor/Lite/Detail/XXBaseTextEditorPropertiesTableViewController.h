//
//  XXBaseTextEditorPropertiesTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/20/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXBaseTextEditorPropertiesTableViewControllerStoryboardID = @"kXXBaseTextEditorPropertiesTableViewControllerStoryboardID";

@interface XXBaseTextEditorPropertiesTableViewController : UITableViewController
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileContent;

@end
