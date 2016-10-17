//
//  XXCodeBlockModel.m
//  XXTouchApp
//
//  Created by Zheng on 9/27/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCodeBlockModel.h"

@implementation XXCodeBlockModel

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code {
    return [self modelWithTitle:title code:code type:kXXCodeBlockTypeInternalFunction];
}

+ (instancetype)modelWithTitle:(NSString *)title code:(NSString *)code type:(kXXCodeBlockType)type {
    XXCodeBlockModel *newModel = [XXCodeBlockModel new];
    newModel.title = title;
    newModel.code = code;
    newModel.currentStep = 0;
    newModel.totalStep = 0;
    return newModel;
}

- (NSString *)udid {
    return [NSString stringWithUUID];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _udid = [aDecoder decodeObjectForKey:@"udid"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _code = [aDecoder decodeObjectForKey:@"code"];
        _currentStep = [[aDecoder decodeObjectForKey:@"currentStep"] unsignedIntegerValue];
        _totalStep = [[aDecoder decodeObjectForKey:@"totalStep"] unsignedIntegerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.udid forKey:@"udid"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.code forKey:@"code"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.currentStep] forKey:@"currentStep"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.totalStep] forKey:@"totalStep"];
}

#pragma mark - Copy

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    XXCodeBlockModel *copy = [[[self class] allocWithZone:zone] init];
    copy.udid = [self.udid copyWithZone:zone];
    copy.title = [self.title copyWithZone:zone];
    copy.code = [self.code copyWithZone:zone];
    copy.currentStep = self.currentStep;
    copy.totalStep = self.totalStep;
    return copy;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    XXCodeBlockModel *copy = [[[self class] allocWithZone:zone] init];
    copy.udid = [self.udid mutableCopyWithZone:zone];
    copy.title = [self.title mutableCopyWithZone:zone];
    copy.code = [self.code mutableCopyWithZone:zone];
    copy.currentStep = self.currentStep;
    copy.totalStep = self.totalStep;
    return copy;
}

@end
