//
//  XXLuaVModel.h
//  XXTouchApp
//
//  Created by Zheng on 31/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XXLuaVModel;

@protocol XXLuaVModelDelegate <NSObject>
- (void)luaWillLoad:(XXLuaVModel *)vm;
- (void)luaDidLoad:(XXLuaVModel *)vm error:(NSError *)error;
- (void)luaWillLaunch:(XXLuaVModel *)vm;
- (void)luaDidLaunch:(XXLuaVModel *)vm;
- (void)luaDidTerminate:(XXLuaVModel *)vm error:(NSError *)error;

@end

@interface XXLuaVModel : NSObject
@property (nonatomic, weak) id<XXLuaVModelDelegate> delegate;

- (BOOL)loadBufferFromString:(NSString *)string error:(NSError **)error;

@end
