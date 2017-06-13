//
//  NSError+LocalizedDescription.m
//  XXTouchApp
//
//  Created by Zheng on 10/06/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "NSError+LocalizedDescription.h"

@implementation NSError (LocalizedDescription)

- (NSString *)customDescription {
    if ([self.domain isEqualToString:NSURLErrorDomain] && self.code == -1004) {
        return NSLocalizedString(@"Could not connect to the server.", nil);
    }
    return [self localizedDescription];
}

@end
