//
//  AppDelegate.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import "XUIListController.h"
#import "XXNavigationViewController.h"
#import "XXEmptyNavigationController.h"
#import "XXLocalDataService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GlobalSettings sharedInstance];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BOOL rootLoaded = NO;
    if (rootLoaded ||
        [self loadRootWithXUI:extendDict()[@"ROOT_UI"]]) {
        rootLoaded = YES;
    }
    if (rootLoaded ||
        [self loadRootWithMain]) {
        rootLoaded = YES;
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return rootLoaded;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (shortcutItem) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kXXGlobalNotificationLaunch object:shortcutItem.type userInfo:@{kXXGlobalNotificationKeyEvent: kXXGlobalNotificationKeyEventShortcut}]];
        if (completionHandler) {
            completionHandler(YES);
        }
        return;
    } else if (completionHandler) {
        completionHandler(NO);
    }
}

- (BOOL)handleUrlTransfer:(NSURL *)url {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kXXGlobalNotificationLaunch object:url userInfo:@{kXXGlobalNotificationKeyEvent: kXXGlobalNotificationKeyEventInbox}]];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        return [self handleUrlTransfer:url];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(id)annotation {
    return [self application:application openURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(nonnull NSDictionary<NSString *,id> *)options
{
    return [self application:application openURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"xxt"]) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url
                                                    resolvingAgainstBaseURL:NO];
        if ([urlComponents.host isEqualToString:@"root"]) {
            START_IGNORE_PARTIAL
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                NSArray *queryItems = urlComponents.queryItems;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"path"];
                NSURLQueryItem *queryValue = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
                if (queryValue && queryValue.value) {
                    NSString *uiPath = queryValue.value;
                    [self loadRootWithXUI:uiPath];
                }
                return YES;
            } else {
                NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
                NSArray *urlQuery = [[urlComponents query] componentsSeparatedByString:@"&"];
                for (NSString *keyValuePair in urlQuery)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [[pairComponents firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *value = [[pairComponents lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    if (key && value) {
                        [queryStringDictionary setObject:value forKey:key];
                    }
                }
                NSString *uiPath = queryStringDictionary[@"path"];
                [self loadRootWithXUI:uiPath];
            }
            END_IGNORE_PARTIAL
        }
    }
    return [self handleUrlTransfer:url];
}

- (UIViewController *)loadRootWithXUI:(NSString *)uiPath {
    if (!uiPath || uiPath.length == 0) return nil;
    if (![uiPath isAbsolutePath]) {
        uiPath = [[XXTGSSI.dataService rootPath] stringByAppendingPathComponent:uiPath];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:uiPath]) return nil;
    XUIListController *listController = [[XUIListController alloc] init];
    listController.filePath = uiPath;
    XXEmptyNavigationController *navController = [[XXEmptyNavigationController alloc] initWithRootViewController:listController];
    self.window.rootViewController = navController;
    return navController;
}

- (UIViewController *)loadRootWithMain {
    XXNavigationViewController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kXXRootNavigationControllerStoryboardID];
    self.window.rootViewController = navController;
    return navController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
