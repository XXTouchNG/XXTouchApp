//
//  XXEditorFontSettingsTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 01/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXEditorFontSettingsTableViewControllerStoryboardID = @"kXXEditorFontSettingsTableViewControllerStoryboardID";

@class XXEditorFontSettingsTableViewController;

@protocol XXEditorFontSettingsTableViewControllerDelegate <NSObject>
- (void)editorFontSettingsDidEdited:(XXEditorFontSettingsTableViewController *)controller;

@end

@interface XXEditorFontSettingsTableViewController : UITableViewController
@property (nonatomic, weak) id<XXEditorFontSettingsTableViewControllerDelegate> delegate;

@end
