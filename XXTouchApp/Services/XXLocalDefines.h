//
//  XXLocalDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef XXLocalDefines_h
#define XXLocalDefines_h

static NSString * const apiUrl = @"http://127.0.0.1:46952/";
static NSString * const remoteAccessUrl = @"http://%@:46952/";

typedef enum : NSUInteger {
    kXXLocalCommandMethodGET  = 0,
    kXXLocalCommandMethodPOST = 1,
} XXLocalCommandMethod;

#endif /* XXLocalDefines_h */
