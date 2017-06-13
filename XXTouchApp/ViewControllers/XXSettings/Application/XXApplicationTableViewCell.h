//
//  XXApplicationTableViewCell.h
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXApplicationTableViewCell : UITableViewCell

- (void)setApplicationName:(NSString *)name;

- (NSString *)applicationBundleID;
- (void)setApplicationBundleID:(NSString *)bundleID;
- (void)setApplicationIconImage:(UIImage *)image;

@end
