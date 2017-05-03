//
//  XXAddCodeBlockTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/28/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXTPickerTask.h"

static NSString * const kXXStorageKeyCodeBlockInternalFunctions = @"kXXStorageKeyCodeBlockInternalFunctions";
static NSString * const kXXStorageKeyCodeBlockUserDefinedFunctions = @"kXXStorageKeyCodeBlockUserDefinedFunctions";

@interface XXAddCodeBlockTableViewController : UITableViewController
@property (nonatomic, strong) XXTPickerTask *pickerTask;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) NSMutableArray <XXTPickerTask *> *pickerTasks;

@end
