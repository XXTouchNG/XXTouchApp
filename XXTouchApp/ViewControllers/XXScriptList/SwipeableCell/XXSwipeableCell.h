//
//  XXSwipeableCell.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface XXSwipeableCell : MGSwipeTableCell
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL selectBootscript;
@property (nonatomic, strong) NSDictionary *itemAttrs;

@property (nonatomic, assign, readonly) BOOL isSelectable;
@property (nonatomic, assign, readonly) BOOL isEditable;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign, readonly) BOOL isSymbolicLink;
@property (nonatomic, assign, readonly) BOOL canOperate;
@end
