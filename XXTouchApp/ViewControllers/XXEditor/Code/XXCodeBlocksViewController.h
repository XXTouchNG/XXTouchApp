//
//  XXCodeBlocksViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/25/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XXTPickerCollection/XXTPickerCollection.h>

static NSString * const kXXCodeBlocksTableViewControllerStoryboardID = @"kXXCodeBlocksTableViewControllerStoryboardID";

@interface XXCodeBlocksViewController : UIViewController
@property (nonatomic, weak) UITextView *textInput;

- (void)replaceTextInputSelectedRangeWithModel:(XXTPickerTask *)model;
@end
