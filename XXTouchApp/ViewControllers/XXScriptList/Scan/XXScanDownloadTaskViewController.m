//
//  XXScanDownloadTaskViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXScanDownloadTaskViewController.h"
#import "XXScanDownloadSourceHeadersTableViewController.h"
#import "XXLocalDataService.h"

@interface XXScanDownloadTaskViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadButton;
@property (nonatomic, copy) NSString *rootDirectory;

@property (nonatomic, assign) BOOL sameName;

@end

@implementation XXScanDownloadTaskViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sourceLabel.text = self.sourceUrl;
    self.destinationLabel.text = self.destinationUrl;
    
    self.clearsSelectionOnViewWillAppear = YES;
    NSURL *url = [NSURL URLWithString:[self.sourceUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    if (!url) {
        self.sourceLabel.textColor = [UIColor redColor];
        self.downloadButton.enabled = NO;
    } else {
        BOOL urlAccess = [[UIApplication sharedApplication] canOpenURL:url];
        if (!urlAccess) {
            self.sourceLabel.textColor = [UIColor redColor];
            self.downloadButton.enabled = NO;
        } else {
            self.sourceUrl = [url absoluteString]; // Encoded
        }
    }
    self.rootDirectory = [ROOT_PATH copy];
    NSURL *rootUrl = [NSURL fileURLWithPath:[self.rootDirectory stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
    NSString *relativePath = [self.destinationUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSURL *destination = nil;
    if ([relativePath hasPrefix:@"/"]) {
        destination = [NSURL fileURLWithPath:relativePath];
    } else {
        destination = [NSURL URLWithString:relativePath relativeToURL:rootUrl];
    }
    if (!destination) {
        self.destinationLabel.textColor = [UIColor redColor];
        self.downloadButton.enabled = NO;
    } else {
        self.destinationUrl = [[destination path] stringByRemovingPercentEncoding]; // Decoded
        if ([FCFileManager existsItemAtPath:self.destinationUrl]) {
            self.destinationLabel.textColor = [UIColor redColor];
            _sameName = YES;
        }
    }
}

- (IBAction)download:(id)sender {
    if (_sameName) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Overwrite Confirm", nil)
                                                         andMessage:[NSString stringWithFormat:NSLocalizedString(@"File \"%@\" exists, overwrite it?", nil), self.destinationLabel.text]];
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil) type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            [self downloadNow];
        }];
        [alertView show];
    } else {
        [self downloadNow];
    }
}

- (void)downloadNow {
    if (_delegate && [_delegate respondsToSelector:@selector(confirmDownloadTask:source:destination:)]) {
        [_delegate confirmDownloadTask:self
                                source:self.sourceUrl // Encoded
                           destination:self.destinationUrl]; // Decoded
    }
}

- (IBAction)cancel:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(cancelDownloadTask:)]) {
        [_delegate cancelDownloadTask:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIPasteboard generalPasteboard] setString:self.sourceUrl];
            [self.navigationController.view makeToast:NSLocalizedString(@"Source URL has been copied to the clipboard", nil)];
        } else if (indexPath.row == 1) {
            [[UIPasteboard generalPasteboard] setString:self.destinationUrl];
            [self.navigationController.view makeToast:NSLocalizedString(@"Destination path has been copied to the clipboard", nil)];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    ((XXScanDownloadSourceHeadersTableViewController *)segue.destinationViewController).url = self.sourceUrl;
}

@end
