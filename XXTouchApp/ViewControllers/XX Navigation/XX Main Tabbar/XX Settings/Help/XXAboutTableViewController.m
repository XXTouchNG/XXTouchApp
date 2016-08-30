//
//  XXAboutTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

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
    
    self.title = NSLocalizedStringFromTable(@"About", @"XXTouch", nil);
    _appLabel.text = [NSString stringWithFormat:@"%@\nV%@ (%@)", APP_NAME_CN, VERSION_STRING, VERSION_BUILD];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case kOptionSection:
            switch (indexPath.row) {
                case kOptionOfficialSiteIndex:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:OFFICIAL_SITE]];
                    break;
                case kOptionMailFeedbackIndex:
                    [self displayComposerSheet];
                    break;
                case kOptionUserAgreementIndex:
                    break;
                case kOptionThirdPartyIndex:
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
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
    [self.navigationController.view makeToast:NSLocalizedStringFromTable(@"Enable Debug Mode", @"XXTouch", nil)
                                     duration:STYLE_TOAST_DURATION
                                     position:CSToastPositionCenter];
    [[FLEXManager sharedManager] showExplorer];
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
    [picker setSubject:[NSString stringWithFormat:@"[%@] %@\nV%@ (%@)", NSLocalizedStringFromTable(@"Feedback", @"XXTouch", nil), APP_NAME_CN, VERSION_STRING, VERSION_BUILD]];
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

@end
