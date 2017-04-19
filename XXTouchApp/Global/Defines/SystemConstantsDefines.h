//
//  SystemConstantsDefines.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#ifndef SystemConstantsDefines_h
#define SystemConstantsDefines_h

static NSString * const kXXGlobalNotificationList = @"kXXGlobalNotificationList";

static NSString * const kXXGlobalNotificationKeyEvent = @"kXXGlobalNotificationKeyEvent";
static NSString * const kXXGlobalNotificationKeyEventArchive = @"kXXGlobalNotificationKeyEventArchive";
static NSString * const kXXGlobalNotificationKeyEventUnarchive = @"kXXGlobalNotificationKeyEventUnarchive";
static NSString * const kXXGlobalNotificationKeyEventTransfer = @"kXXGlobalNotificationKeyEventTransfer";

static NSString * const kXXGlobalNotificationLaunch = @"kXXGlobalNotificationLaunch";

static NSString * const kXXGlobalNotificationKeyEventShortcut = @"kXXGlobalNotificationKeyEventShortcut";
static NSString * const kXXGlobalNotificationKeyEventInbox = @"kXXGlobalNotificationKeyEventInbox";

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

#define STYLE_TINT_COLOR [UIColor colorWithRed:26.f/255.f green:161.f/255.f blue:230.f/255.f alpha:1.f]

#define START_IGNORE_PARTIAL _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wpartial-availability\"")
#define END_IGNORE_PARTIAL _Pragma("clang diagnostic pop")

#endif /* SystemConstantsDefines_h */
