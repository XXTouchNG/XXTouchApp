//
//  XXLocationPicker.h
//  XXTouchApp
//
//  Created by Zheng on 9/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

static NSString * const kXXLocationPickerTableViewControllerStoryboardID = @"kXXLocationPickerTableViewControllerStoryboardID";

@interface XXLocationPicker : UITableViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;

@end
