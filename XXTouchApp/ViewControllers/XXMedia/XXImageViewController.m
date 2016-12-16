//
//  XXImageViewController.m
//  XXTouchApp
//
//  Created by Zheng on 14/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXImageViewController.h"

@interface XXImageViewController () <IDMPhotoBrowserDelegate>

@end

@implementation XXImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

#pragma mark - IDMPhotoBrowserDelegate

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index {
    if (self.activity && !self.activity.activeDirectly) {
        [self.activity activityDidFinish:YES];
    }
}

@end
