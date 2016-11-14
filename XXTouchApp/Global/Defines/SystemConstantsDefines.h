//
//  SystemConstantsDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <pthread.h>

#ifndef SystemConstantsDefines_h
#define SystemConstantsDefines_h

static NSString * const kXXGlobalNotificationName = @"kXXGlobalNotificationName";
static NSString * const kXXGlobalNotificationKeyEvent = @"kXXGlobalNotificationKeyEvent";
static NSString * const kXXGlobalNotificationKeyEventArchive = @"kXXGlobalNotificationKeyEventArchive";
static NSString * const kXXGlobalNotificationKeyEventUnarchive = @"kXXGlobalNotificationKeyEventUnarchive";
static NSString * const kXXGlobalNotificationKeyEventTransfer = @"kXXGlobalNotificationKeyEventTransfer";

#define ROOTNAV ([AppDelegate globalDelegate].rootViewController)
#define STORYBOARD ([AppDelegate globalDelegate].rootViewController.storyboard)

#define SendConfigAction(command, reload) \
self.navigationController.view.userInteractionEnabled = NO; \
[self.navigationController.view makeToastActivity:CSToastPositionCenter]; \
@weakify(self); \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ \
    @strongify(self); \
    __block NSError *err = nil; \
    BOOL result = command; \
    dispatch_async_on_main_queue(^{ \
        self.navigationController.view.userInteractionEnabled = YES; \
        [self.navigationController.view hideToastActivity]; \
        if (!result) { \
            [self.navigationController.view makeToast:[err localizedDescription]]; \
        } else { \
            reload; \
        } \
    }); \
});

#endif /* SystemConstantsDefines_h */
