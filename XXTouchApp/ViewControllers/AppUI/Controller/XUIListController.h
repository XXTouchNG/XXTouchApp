//
//  XUIListController.h
//  XXTouchApp
//
//  Created by Zheng on 14/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XUITintedListController.h"
#import "XXBaseActivity.h"

@interface XUIListController : XUITintedListController <XUIListControllerProtocol>
@property (nonatomic, weak) XXBaseActivity *activity;
@property (nonatomic, copy) NSString *filePath;

@end
