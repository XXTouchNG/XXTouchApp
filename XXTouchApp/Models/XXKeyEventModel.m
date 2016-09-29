//
//  XXKeyEventModel.m
//  XXTouchApp
//
//  Created by Zheng on 9/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyEventModel.h"

@implementation XXKeyEventModel

+ (instancetype)modelWithTitle:(NSString *)title command:(NSString *)command {
    XXKeyEventModel *newModel = [XXKeyEventModel new];
    newModel.title = title;
    newModel.command = command;
    return newModel;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _command = [aDecoder decodeObjectForKey:@"command"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.command forKey:@"command"];
}

#pragma mark - Copy

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    XXKeyEventModel *copy = [[[self class] allocWithZone:zone] init];
    copy.title = [self.title copyWithZone:zone];
    copy.command = [self.command copyWithZone:zone];
    return copy;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    XXKeyEventModel *copy = [[[self class] allocWithZone:zone] init];
    copy.title = [self.title mutableCopyWithZone:zone];
    copy.command = [self.command mutableCopyWithZone:zone];
    return copy;
}

@end
