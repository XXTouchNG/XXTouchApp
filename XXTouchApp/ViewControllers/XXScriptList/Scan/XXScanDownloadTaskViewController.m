//
//  XXScanDownloadTaskViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/15/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXScanDownloadTaskViewController.h"
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
    
    
    NSURL *url = [NSURL URLWithString:[self.sourceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (!url) {
        self.sourceLabel.textColor = [UIColor redColor];
        self.downloadButton.enabled = NO;
    }
    BOOL urlAccess = [[UIApplication sharedApplication] canOpenURL:url];
    if (!urlAccess) {
        self.sourceLabel.textColor = [UIColor redColor];
        self.downloadButton.enabled = NO;
    } else {
        self.sourceUrl = [url absoluteString];
    }
    self.rootDirectory = [ROOT_PATH copy];
    NSURL *rootUrl = [NSURL fileURLWithPath:[self.rootDirectory stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *destination = [NSURL fileURLWithPath:[self.destinationUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                  relativeToURL:rootUrl];
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

@end
