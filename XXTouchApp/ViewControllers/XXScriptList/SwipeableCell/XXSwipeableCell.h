//
//  XXSwipeableCell.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

static NSString * const kXXItemPathKey = @"kXXItemPathKey";
static NSString * const kXXItemNameKey = @"kXXItemNameKey";

@interface XXSwipeableCell : MGSwipeTableCell
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL selectBootscript;
@property (nonatomic, strong) NSDictionary *itemAttrs;

@property (nonatomic, assign) BOOL isSelectable;
@property (nonatomic, assign) BOOL isEditable;
@property (nonatomic, assign) BOOL isDirectory;
@end
