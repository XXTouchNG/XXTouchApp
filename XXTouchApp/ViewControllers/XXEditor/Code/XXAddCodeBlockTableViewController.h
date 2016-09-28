//
//  XXAddCodeBlockTableViewController.h
//  XXTouchApp
//
//  Created by Zheng on 9/28/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXCodeBlockModel.h"

@interface XXAddCodeBlockTableViewController : UITableViewController
@property (nonatomic, strong) XXCodeBlockModel *codeBlock;
@property (nonatomic, assign) BOOL editMode;

@end
