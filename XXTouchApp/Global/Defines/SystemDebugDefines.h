//
//  SystemDebugDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef SystemDebugDefines_h
#define SystemDebugDefines_h

#ifdef DEBUG
#define CYLog(fmt, ...) NSLog((@"\n[%@:%d]\n%s\n" fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define NSLog(...);
#define CYLog(...);
#endif

#endif /* SystemDebugDefines_h */
