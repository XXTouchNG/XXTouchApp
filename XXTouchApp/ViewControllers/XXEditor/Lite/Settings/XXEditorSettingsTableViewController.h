//
//  XXEditorSettingsTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 01/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXEditorSettingsTableViewControllerStoryboardID = @"kXXEditorSettingsTableViewControllerStoryboardID";

@class XXEditorSettingsTableViewController;

@protocol XXEditorSettingsTableViewControllerDelegate <NSObject>
- (void)editorSettingsDidEdited:(XXEditorSettingsTableViewController *)controller inSection:(NSUInteger)section;

@end

@interface XXEditorSettingsTableViewController : UITableViewController
@property (nonatomic, weak) id<XXEditorSettingsTableViewControllerDelegate> delegate;

@end
