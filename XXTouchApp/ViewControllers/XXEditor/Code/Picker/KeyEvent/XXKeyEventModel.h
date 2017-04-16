//
//  XXKeyEventModel.h
//  XXTouchApp
//
//  Created by Zheng on 9/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXKeyEventModel : NSObject <NSCopying, NSMutableCopying, NSCoding>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *command;

+ (instancetype)modelWithTitle:(NSString *)title command:(NSString *)command;
@end
