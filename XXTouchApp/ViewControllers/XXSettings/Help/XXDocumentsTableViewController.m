//
//  XXDocumentsTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/31/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXDocumentsTableViewController.h"
#import "XXWebViewController.h"

#define DOCUMENT_USERS_GUIDE @"https://www.zybuluo.com/xxtouch/note/378784"
#define DOCUMENT_UPDATE_LOGS @"https://www.zybuluo.com/xxtouch/note/386289"
#define DOCUMENT_DEVELOPER_REFERENCE @"https://www.zybuluo.com/xxtouch/note/370734"
#define DOCUMENT_OPEN_API_REFERENCE @"https://www.zybuluo.com/xxtouch/note/386268"
#define DOCUMENT_CODE_SNIPPETS_REFERENCE @"https://www.zybuluo.com/xxtouch/note/716784"
#define DOCUMENT_DYNAMIC_XUI_REFERENCE @"https://www.zybuluo.com/xxtouch/note/716787"

enum {
    kDocumentSection = 0,
};

enum {
    kUsersGuideIndex          = 0,
    kUpdateLogsIndex          = 1,
    kDeveloperReferenceIndex = 2,
    kOpenApiReferenceIndex   = 3,
    kCodeSnippetReferenceIndex = 4,
    kDynamicXUIReferenceIndex = 5
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
        return 6;
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
            documentUrl = DOCUMENT_CODE_SNIPPETS_REFERENCE;
        } else if (indexPath.row == kDynamicXUIReferenceIndex) {
            viewController.title = NSLocalizedString(@"DynamicXUI (XUI) Reference", nil);
            documentUrl = DOCUMENT_DYNAMIC_XUI_REFERENCE;
        }
        NSString *documentPath = [documentUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if (documentPath) {
            if (fileUrl) {
                viewController.url = [NSURL fileURLWithPath:documentPath];
            } else {
                viewController.url = [NSURL URLWithString:documentPath];
            }
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
