//
//  XXAboutTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "XXAboutTableViewController.h"

enum {
    kInformationSection = 0,
    kOptionSection      = 1,
};

// Index - kInformationSection
enum {
    kInformationIndex = 0,
};

// Index - kOptionSection
enum {
    kOptionOfficialSiteIndex   = 0,
    kOptionMailFeedbackIndex   = 1,
    kOptionUserAgreementIndex  = 2,
    kOptionThirdPartyIndex     = 3,
};

@interface XXAboutTableViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (nonatomic, strong) UIBarButtonItem *debugItem;

@end

@implementation XXAboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = XXLString(@"About");
    _appLabel.text = [NSString stringWithFormat:@"%@\nV%@ (%@)", APP_NAME_CN, VERSION_STRING, VERSION_BUILD];
}

- (UIBarButtonItem *)debugItem {
    if (!_debugItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                       target:self
                                                                                       action:@selector(debugViaFlex:) ];
        _debugItem = anotherButton;
    }
    return _debugItem;
}

- (void)debugViaFlex:(id)sender {
    [self.navigationController.view makeToast:XXLString(@"Enable Debug Mode")];
#ifdef DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = self.debugItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

// Action - kOptionMailFeedbackIndex

- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) return;
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat:@"[%@] %@\nV%@ (%@)", XXLString(@"Feedback"), APP_NAME_CN, VERSION_STRING, VERSION_BUILD]];
    NSArray *toRecipients = [NSArray arrayWithObject:SERVICE_EMAIL];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kOptionSection:
            switch (indexPath.row) {
                case kOptionOfficialSiteIndex:
                    [self openOfficialSite];
                    break;
                case kOptionMailFeedbackIndex:
                    [self displayComposerSheet];
                    break;
                case kOptionUserAgreementIndex:
                    [self openUserAgreement];
                    break;
                case kOptionThirdPartyIndex:
                    [self openThirdParty];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)openOfficialSite {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = XXLString(@"Official Site");
    viewController.url = [NSURL URLWithString:OFFICIAL_SITE];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openUserAgreement {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = XXLString(@"User Agreement");
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tos" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openThirdParty {
    XXWebViewController *viewController = [[XXWebViewController alloc] init];
    viewController.title = XXLString(@"Third Party Credits");
    viewController.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"open" ofType:@"html"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dealloc {
    CYLog(@"");
}

@end
