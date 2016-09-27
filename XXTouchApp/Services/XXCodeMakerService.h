//
//  XXCodeMakerService.h
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXCodeBlockModel.h"

@interface XXCodeMakerService : NSObject
+ (void)pushToMakerWithCodeBlockModel:(XXCodeBlockModel *)model controller:(UIViewController *)controller;

@end
