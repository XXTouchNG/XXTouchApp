//
//  XXTApplicationCell.h
//  XXTPickerCollection
//
//  Created by Zheng on 03/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXTApplicationCellReuseIdentifier = @"kXXTApplicationCellReuseIdentifier";

@interface XXTApplicationCell : UITableViewCell

- (void)setApplicationName:(NSString *)name;

- (NSString *)applicationBundleID;
- (void)setApplicationBundleID:(NSString *)bundleID;

- (void)setApplicationIconData:(NSData *)iconData;

@end
