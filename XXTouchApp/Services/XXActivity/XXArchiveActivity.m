//
//  XXArchiveActivity.m
//  XXTouchApp
//
//  Created by Zheng on 09/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXArchiveActivity.h"
#import <SSZipArchive/SSZipArchive.h>

@interface XXArchiveActivity ()
@property (nonatomic, strong) NSArray <NSString *> *items;

@end

@implementation XXArchiveActivity

+ (NSArray <NSString *> *)supportedExtensions {
    return @[ ];
}

- (NSString *)activityType
{
    return @"com.xxtouch.activity-archive";
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Archive Files", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity-archive"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems.count >= 1) {
        if ([activityItems[0] isKindOfClass:[NSString class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.items = activityItems;
    if (activityItems.count >= 1) {
        self.fileURL = [NSURL fileURLWithPath:activityItems[0]];
    }
}

- (void)performActivity
{
    UIViewController *viewController = self.baseController;
    NSString *filePath = self.items[0];
    NSString *path = [filePath stringByDeletingLastPathComponent];
    
    __block UINavigationController *navController = viewController.navigationController;
    navController.view.userInteractionEnabled = NO;
    [navController.view makeToastActivity:CSToastPositionCenter];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *destination = path;
        NSString *archiveName = nil;
        if (self.items.count == 1) {
            archiveName = [self.items[0] lastPathComponent];
        } else {
            archiveName = @"Archive";
        }
        NSString *archiveFullname = [archiveName stringByAppendingPathExtension:@"zip"];
        NSString *archivePath = [destination stringByAppendingPathComponent:archiveFullname];
        if ([FCFileManager existsItemAtPath:archivePath]) {
            NSUInteger testIndex = 2;
            do {
                archivePath = [destination stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%lu.zip", archiveName, (unsigned long)testIndex]];
                testIndex++;
            } while ([FCFileManager existsItemAtPath:archivePath]);
        }
        BOOL result = [SSZipArchive createZipFileAtPath:archivePath
                                    withContentsOfItems:self.items
                                    keepParentDirectory:NO
                                           withPassword:nil
                                               delegate:nil];
        dispatch_async_on_main_queue(^{
            if (_delegate && [_delegate respondsToSelector:@selector(archiveDidCreatedAtPath:)]) {
                [_delegate archiveDidCreatedAtPath:archivePath];
            }
            navController.view.userInteractionEnabled = YES;
            [navController.view hideToastActivity];
            if (!result) {
                [navController.view makeToast:NSLocalizedString(@"Cannot create zip file", nil)];
            } else {
                [navController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
            }
        });
    });
    
    [self activityDidFinish:YES];
}

@end
