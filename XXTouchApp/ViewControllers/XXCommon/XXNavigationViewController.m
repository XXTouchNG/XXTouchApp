//
//  XXNavigationViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXNavigationViewController.h"
#import "XXLocalNetService.h"

static NSString * const kXXLaunchScreenStoryboardID = @"kXXLaunchScreenStoryboardID";

@interface XXNavigationViewController ()
@property (nonatomic, assign) BOOL firstLaunched;

@end

@implementation XXNavigationViewController

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_firstLaunched) {
        _firstLaunched = YES;
        [self resetLaunchScreen];
        self.view.hidden = NO;
    }
}

- (void)resetLaunchScreen {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:kXXLaunchScreenStoryboardID];
    UIView *launchView = viewController.view;
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    launchView.frame = [UIApplication sharedApplication].keyWindow.frame;
    [mainWindow addSubview:launchView];
    [self launchSetup:launchView];
}

- (void)launchSetup:(UIView *)launchView {
    [launchView makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        sleep(1);
        BOOL result = [[XXLocalNetService sharedInstance] localGetSelectedScript];
        dispatch_async_on_main_queue(^{
            if (!result) {
                [launchView hideToastActivity];
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:XXLString(@"Launch Failure")
                                                                 andMessage:XXLString(@"Failed to sync with daemon.\nTap to retry.")];
                [alertView addButtonWithTitle:XXLString(@"Retry")
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alertView) {
                                          [self performSelector:@selector(launchSetup:) withObject:launchView afterDelay:0.5];
                                      }];
                [alertView show];
            } else {
                [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    launchView.alpha = 0.0f;
                    launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.0f, 2.0f, 1.0f);
                } completion:^(BOOL finished) {
                    [launchView hideToastActivity];
                    [launchView removeFromSuperview];
                }];
            }
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
