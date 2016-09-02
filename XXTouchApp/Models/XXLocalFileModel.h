//
//  XXLocalFileModel.h
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface XXLocalFileModel : JSONModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger change;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger access;
@property (nonatomic, assign) NSInteger gid;
@property (nonatomic, assign) NSInteger blksize;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger rdev;
@property (nonatomic, assign) NSInteger blocks;
@property (nonatomic, assign) NSInteger nlink;
@property (nonatomic, copy) NSString *permissions;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, assign) NSInteger dev;
@property (nonatomic, assign) NSInteger ino;
@property (nonatomic, assign) NSInteger modification;

@end
