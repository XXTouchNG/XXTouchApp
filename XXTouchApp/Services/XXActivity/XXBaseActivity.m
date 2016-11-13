//
//  XXBaseActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseActivity.h"

@implementation XXBaseActivity

- (instancetype)initWithViewController:(UIViewController *)controller {
    if (self = [super init]) {
        self.baseController = controller;
    }
    return self;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count >= 1) {
        if ([activityItems[0] isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count >= 1) {
        if ([activityItems[0] isKindOfClass:[NSURL class]]) {
            self.fileURL = activityItems[0];
        }
    }
}

+ (NSArray <NSString *> *)supportedExtensions {
    return @[];
}

- (void)performActivity
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self presentActivity];
    } else {
        self.baseController.navigationController.view.userInteractionEnabled = NO;
        [self.baseController.navigationController.view makeToastActivity:CSToastPositionCenter];
        [self performSelector:@selector(presentActivity) withObject:nil afterDelay:1.f];
    }
    [self activityDidFinish:YES];
}

- (void)presentActivity {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
    } else {
        [self.baseController.navigationController.view hideToastActivity];
        self.baseController.navigationController.view.userInteractionEnabled = YES;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
