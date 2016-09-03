//
//  XXSwipeableCell.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXSwipeableCell : UITableViewCell
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *itemPath;
@property (nonatomic, strong) NSDictionary *itemAttrs;

@end
