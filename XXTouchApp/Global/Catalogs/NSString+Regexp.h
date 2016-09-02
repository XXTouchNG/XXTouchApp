//
//  NSString+Regexp.h
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regexp)
- (BOOL)validateWithRegExp:(NSString *)regExp;
@end
