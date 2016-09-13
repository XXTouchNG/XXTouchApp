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

@interface XXKeyPressConfigActionTableViewController ()

@end

#warning check if activator is installed

@implementation XXKeyPressConfigActionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    SendConfigAction([XXLocalNetService localGetVolumeActionConfWithError:&err], [self reloadCheckmark]);
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
    } else if (row == kXXKeyPressConfigPressVolumeDownSection) {
        destinationController.title = XXLString(@"Down Press");
    } else if (row == kXXKeyPressConfigHoldVolumeUpSection) {
        destinationController.title = XXLString(@"Up Short Hold");
    } else if (row == kXXKeyPressConfigHoldVolumeDownSection) {
        destinationController.title = XXLString(@"Down Short Hold");
    }
    destinationController.currentSection = row;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadCheckmark {
    self.tableView.allowsSelection = ![[XXLocalDataService sharedInstance] keyPressConfigActivatorInstalled];
}

@end
