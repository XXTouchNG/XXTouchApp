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
#import "XXLuaInterpreter.h"
#import <Foundation/Foundation.h>

@class XXLuaVModel;

@protocol XXLuaVModelDelegate <NSObject>
- (void)virtualMachineDidChangedState:(XXLuaVModel *)vm;

@end

@interface XXLuaVModel : XXLuaInterpreter
@property (nonatomic, weak) id<XXLuaVModelDelegate> delegate;
@property (nonatomic, assign) FILE *stdoutHandler;
@property (nonatomic, assign) FILE *stderrHandler;
@property (nonatomic, assign) FILE *stdinReadHandler;
@property (nonatomic, assign) FILE *stdinWriteHandler;
@property (nonatomic, assign) BOOL running;

- (BOOL)loadFileFromPath:(NSString *)path error:(NSError **)error;
- (BOOL)loadBufferFromString:(NSString *)string error:(NSError **)error;
- (BOOL)pcallWithError:(NSError **)error;

@end
