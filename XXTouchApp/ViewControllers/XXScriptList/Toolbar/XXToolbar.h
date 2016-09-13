//
//  XXToolbar.h
//  XXTouchApp
//
//  Created by Zheng on 8/31/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXToolbarDelegate <NSObject>
- (void)toolbarButtonTapped:(UIBarButtonItem *)sender;

@end

@interface XXToolbar : UIToolbar
@property (nonatomic, strong) NSArray <UIBarButtonItem *> *defaultToolbarButtons;
@property (nonatomic, strong) NSArray <UIBarButtonItem *> *editingToolbarButtons;
@property (nonatomic, strong) NSArray <UIBarButtonItem *> *selectingBootscriptButtons;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;
@property (nonatomic, strong) UIBarButtonItem *scanButton;
@property (nonatomic, strong) UIBarButtonItem *compressButton;
@property (nonatomic, strong) UIBarButtonItem *addItemButton;
@property (nonatomic, strong) UIBarButtonItem *sortByButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (nonatomic, strong) UIBarButtonItem *pasteButton;
@property (nonatomic, strong) UIBarButtonItem *trashButton;

@property (nonatomic, weak) id <XXToolbarDelegate> tapDelegate;

@end
