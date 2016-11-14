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
@property (nonatomic, strong) NSArray <NSURL *> *items;

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

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    [super prepareWithActivityItems:activityItems];
    self.items = activityItems;
}

- (void)performActivityWithController:(UIViewController *)controller
{
    [super performActivityWithController:controller];
    
    UINavigationController *navController = controller.navigationController;
    NSString *filePath = [self.items[0] path];
    
    NSString *formatString = nil;
    NSString *archiveName = nil;
    if (self.items.count == 1) {
        archiveName = [self.items[0] lastPathComponent];
        formatString = [NSString stringWithFormat:NSLocalizedString(@"Compress 1 item?", nil)];
    } else {
        archiveName = @"Archive";
        formatString = [NSString stringWithFormat:NSLocalizedString(@"Compress %d items?", nil), self.items.count];
    }
    
    NSMutableArray <NSString *> *pathsArr = [[NSMutableArray alloc] init];
    for (NSURL *url in self.items) {
        [pathsArr addObject:[url path]];
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Archive Confirm", nil)
                                                     andMessage:formatString];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        NSString *destinationRootPath = [filePath stringByDeletingLastPathComponent];
        NSString *destination = destinationRootPath;
        NSString *archiveFullname = [archiveName stringByAppendingPathExtension:@"zip"];
        NSString *archivePath = [destination stringByAppendingPathComponent:archiveFullname];
        if ([[NSFileManager defaultManager] fileExistsAtPath:archivePath]) {
            NSUInteger testIndex = 2;
            do {
                archivePath = [destination stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%lu.zip", archiveName, (unsigned long)testIndex]];
                testIndex++;
            } while ([[NSFileManager defaultManager] fileExistsAtPath:archivePath]);
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [navController.view makeToast:[error localizedDescription]];
        } else {
            navController.view.userInteractionEnabled = NO;
            [navController.view makeToastActivity:CSToastPositionCenter];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                BOOL result = [SSZipArchive createZipFileAtPath:archivePath
                                            withContentsOfItems:pathsArr
                                            keepParentDirectory:NO
                                                   withPassword:nil
                                                       delegate:nil];
                dispatch_async_on_main_queue(^{
                    navController.view.userInteractionEnabled = YES;
                    [navController.view hideToastActivity];
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kXXGlobalNotificationName object:nil userInfo:@{kXXGlobalNotificationKeyEvent: kXXGlobalNotificationKeyEventArchive}]];
                    if (!result) {
                        [navController.view makeToast:NSLocalizedString(@"Cannot create zip file", nil)];
                    } else {
                        [navController.view makeToast:NSLocalizedString(@"Operation completed", nil)];
                    }
                });
            });
        }
    }];
    [alertView show];
    
    [self activityDidFinish:YES];
}

@end
