//
//  XXKeyPressConfigActionTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/12/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXKeyPressConfigActionTableViewController.h"
#import "XXKeyPressConfigOperationTableViewController.h"
#import "XXLocalDataService.h"
#import "XXLocalNetService.h"
#import <objc/runtime.h>	
#import <dlfcn.h>

static NSString * const kXXActivatorLibraryPath = @"/usr/lib/libactivator.dylib";

@interface XXKeyPressConfigActionTableViewController ()
@property (nonatomic, assign) BOOL activatorExists;

@end

#warning check if activator is installed

@implementation XXKeyPressConfigActionTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    if ([FCFileManager existsItemAtPath:kXXActivatorLibraryPath]) {
        self.activatorExists = YES;
    } else {
        self.activatorExists = NO;
        SendConfigAction([XXLocalNetService localGetVolumeActionConfWithError:&err], [self reloadCheckmark]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSUInteger row = [self.tableView indexPathForCell:sender].row;
    XXKeyPressConfigOperationTableViewController *destinationController = segue.destinationViewController;
    if (row == kXXKeyPressConfigPressVolumeUpSection) {
        destinationController.title = XXLString(@"Up Press");
        destinationController.operationDescription = XXLString(@"Press Volume Up Button");
    } else if (row == kXXKeyPressConfigPressVolumeDownSection) {
        destinationController.title = XXLString(@"Down Press");
        destinationController.operationDescription = XXLString(@"Press Volume Down Button");
    } else if (row == kXXKeyPressConfigHoldVolumeUpSection) {
        destinationController.title = XXLString(@"Up Short Hold");
        destinationController.operationDescription = XXLString(@"Hold Volume Up Button");
    } else if (row == kXXKeyPressConfigHoldVolumeDownSection) {
        destinationController.title = XXLString(@"Down Short Hold");
        destinationController.operationDescription = XXLString(@"Hold Volume Down Button");
    }
    destinationController.currentSection = row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.activatorExists) {
        return 2;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadCheckmark {
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender {
    if (self.activatorExists) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath.section == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    CYLog(@"");
}

@end
