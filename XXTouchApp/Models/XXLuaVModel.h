//
//  XXLuaVModel.h
//  XXTouchApp
//
//  Created by Zheng on 31/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"
#import "LuaInterpreter.h"
#import <Foundation/Foundation.h>

@class XXLuaVModel;

@protocol XXLuaVModelDelegate <NSObject>

@end

@interface XXLuaVModel : LuaInterpreter
@property (nonatomic, weak) id<XXLuaVModelDelegate> delegate;

- (BOOL)loadFileFromPath:(NSString *)path error:(NSError **)error;
- (BOOL)loadBufferFromString:(NSString *)string error:(NSError **)error;
- (BOOL)pcallWithError:(NSError **)error;

@end
