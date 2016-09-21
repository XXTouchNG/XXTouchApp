//
//  XXDocumentsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/31/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXDocumentsTableViewController.h"
#import "XXWebViewController.h"

enum {
    kDocumentSection = 0,
};

enum {
    kUsersGuideIndex          = 0,
    kUpdateLogsIndex          = 1,
    kDeveloperReferencesIndex = 2,
    kOpenApiReferencesIndex   = 3,
};

@interface XXDocumentsTableViewController ()

@end

@implementation XXDocumentsTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kDocumentSection) {
        XXWebViewController *viewController = [[XXWebViewController alloc] init];
        if (indexPath.row == kUsersGuideIndex) {
            viewController.title = NSLocalizedString(@"User's Guide", nil);
            viewController.url = [NSURL URLWithString:[DOCUMENT_USERS_GUIDE stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        } else if (indexPath.row == kUpdateLogsIndex) {
            viewController.title = NSLocalizedString(@"Update Logs", nil);
            viewController.url = [NSURL URLWithString:[DOCUMENT_UPDATE_LOGS stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        } else if (indexPath.row == kDeveloperReferencesIndex) {
            viewController.title = NSLocalizedString(@"Developer References", nil);
            viewController.url = [NSURL URLWithString:[DOCUMENT_DEVELOPER_REFERENCES stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        } else if (indexPath.row == kOpenApiReferencesIndex) {
            viewController.title = NSLocalizedString(@"OpenAPI References", nil);
            viewController.url = [NSURL URLWithString:[DOCUMENT_OPEN_API_REFERENCES stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
