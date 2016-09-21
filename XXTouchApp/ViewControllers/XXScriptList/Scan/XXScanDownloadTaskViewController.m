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
    NSURL *url = [NSURL URLWithString:[self.sourceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (!url) {
        self.sourceLabel.textColor = [UIColor redColor];
        self.downloadButton.enabled = NO;
    } else {
        BOOL urlAccess = [[UIApplication sharedApplication] canOpenURL:url];
        if (!urlAccess) {
            self.sourceLabel.textColor = [UIColor redColor];
            self.downloadButton.enabled = NO;
        } else {
            self.sourceUrl = [url absoluteString];
        }
    }
    self.rootDirectory = [ROOT_PATH copy];
    NSURL *rootUrl = [NSURL fileURLWithPath:[self.rootDirectory stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *relativePath = [self.destinationUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        self.destinationUrl = [destination path];
    }
}

- (IBAction)download:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(confirmDownloadTask:source:destination:)]) {
        [_delegate confirmDownloadTask:self
                                source:self.sourceUrl
                           destination:self.destinationUrl];
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
