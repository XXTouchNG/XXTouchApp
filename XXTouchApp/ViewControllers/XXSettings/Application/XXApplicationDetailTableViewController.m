//
//  XXApplicationDetailTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/11/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXApplicationDetailTableViewController.h"
#import "XXApplicationTableViewCell.h"
#import "XXLocalNetService.h"

@interface XXApplicationDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundlePathLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataPathLabel;

@end

enum {
    kXXApplicationDetailCellSection = 0,
    kXXApplicationClearAllCellSection
};

enum {
    kXXApplicationDetailAppNameIndex = 0,
    kXXApplicationDetailBundleIDIndex,
    kXXApplicationDetailBundlePathIndex,
    kXXApplicationDetailDataPathIndex,
};

enum {
    kXXApplicationClearAllIndex = 0
};

@implementation XXApplicationDetailTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES; // Override
    self.title = 
    self.appNameLabel.text = [self.appInfo objectForKey:kXXApplicationKeyAppName];
    self.bundleIDLabel.text = [self.appInfo objectForKey:kXXApplicationKeyBundleID];
    self.bundlePathLabel.text = [self.appInfo objectForKey:kXXApplicationKeyBundlePath];
    self.dataPathLabel.text = [self.appInfo objectForKey:kXXApplicationKeyDataPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kXXApplicationDetailCellSection) {
        switch (indexPath.row) {
            case kXXApplicationDetailAppNameIndex:
                [[UIPasteboard generalPasteboard] setString:self.appNameLabel.text];
                break;
            case kXXApplicationDetailBundleIDIndex:
                [[UIPasteboard generalPasteboard] setString:self.bundleIDLabel.text];
                break;
            case kXXApplicationDetailBundlePathIndex:
                [[UIPasteboard generalPasteboard] setString:self.bundlePathLabel.text];
                break;
            case kXXApplicationDetailDataPathIndex:
                [[UIPasteboard generalPasteboard] setString:self.dataPathLabel.text];
                break;
            default:
                break;
        }
        [self.navigationController.view makeToast:NSLocalizedString(@"Copied to the clipboard", nil)];
    } else if (indexPath.section == kXXApplicationClearAllCellSection) {
        if (indexPath.row == kXXApplicationClearAllIndex) {
            [self clearAppDataIndexSelected];
        }
    }
}

- (void)clearAppDataIndexSelected {
    NSString *bid = [_appInfo objectForKey:kXXApplicationKeyBundleID];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear Application Data", nil)
                                                     andMessage:NSLocalizedString(@"This operation will clear all data of the application, and it cannot be revoked.", nil)];
    @weakify(self);
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Clean Now", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              @strongify(self);
                              SendConfigAction([XXLocalNetService localClearAppData:bid error:&err], [self.navigationController.view makeToast:NSLocalizedString(@"Operation completed", nil)]);
                          }];
    [alertView show];
}

- (void)dealloc {
    CYLog(@"");
}

@end
