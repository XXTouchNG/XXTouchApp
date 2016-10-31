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
    kDeveloperReferenceIndex = 2,
    kOpenApiReferenceIndex   = 3,
    kCodeSnippetReferenceIndex = 4,
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
        return 5;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kDocumentSection) {
        XXWebViewController *viewController = [[XXWebViewController alloc] init];
        BOOL fileUrl = NO;
        NSString *documentUrl = nil;
        if (indexPath.row == kUsersGuideIndex) {
            viewController.title = NSLocalizedString(@"User's Guide", nil);
            documentUrl = DOCUMENT_USERS_GUIDE;
        } else if (indexPath.row == kUpdateLogsIndex) {
            viewController.title = NSLocalizedString(@"Update Logs", nil);
            documentUrl = DOCUMENT_UPDATE_LOGS;
        } else if (indexPath.row == kDeveloperReferenceIndex) {
            viewController.title = NSLocalizedString(@"Developer Reference", nil);
            documentUrl = DOCUMENT_DEVELOPER_REFERENCE;
        } else if (indexPath.row == kOpenApiReferenceIndex) {
            viewController.title = NSLocalizedString(@"OpenAPI Reference", nil);
            documentUrl = DOCUMENT_OPEN_API_REFERENCE;
        } else if (indexPath.row == kCodeSnippetReferenceIndex) {
            viewController.title = NSLocalizedString(@"Code Snippet Reference", nil);
            documentUrl = [[NSBundle mainBundle] pathForResource:@"XXTReferences.bundle/code-snippet-reference" ofType:@"html"];
            fileUrl = YES;
        }
        if (fileUrl) {
            viewController.url = [NSURL fileURLWithPath:[documentUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        } else {
            viewController.url = [NSURL URLWithString:[documentUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
