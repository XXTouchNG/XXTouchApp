//
//  XXLuaVModel.h
//  XXTouchApp
//
//  Created by Zheng on 31/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXLuaVModel : NSObject
- (BOOL)loadBufferFromString:(NSString *)string error:(NSError **)error;

@end
