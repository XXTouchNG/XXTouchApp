//
//  XXSplashModelController.h
//  ExampleCurl
//
//  Created by Zheng on 12/03/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXSplashDataViewController;

@interface XXSplashModelController : NSObject <UIPageViewControllerDataSource>

- (XXSplashDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(XXSplashDataViewController *)viewController;

@end

