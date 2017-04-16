//
//  GlobalSettings.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXLocalDataService.h"

@interface GlobalSettings : NSObject
@property (nonatomic, strong) XXLocalDataService *dataService;

+ (instancetype)sharedInstance;

@end
