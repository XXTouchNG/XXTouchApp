//
//  XXLocalCommandBaseRequest.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalCommandDefines.h"
#import <Foundation/Foundation.h>

@interface XXLocalCommandBaseRequest : NSObject
@property (nonatomic, assign) XXLocalCommandMethod requestMethod;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSString *requestBody;

@end
