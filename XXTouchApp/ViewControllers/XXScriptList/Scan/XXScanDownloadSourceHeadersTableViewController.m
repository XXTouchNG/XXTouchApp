//
//  XXScanDownloadSourceHeadersTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/16/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXScanDownloadSourceHeadersTableViewController.h"

static NSString * const kXXScanDownloadSourceHeadersTableViewCellReuseIdentifier = @"kXXScanDownloadSourceHeadersTableViewCellReuseIdentifier";

@interface XXScanDownloadSourceHeadersTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCopy;
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *headers;
@property (nonatomic, strong) NSArray <NSString *> *headerKeys;
@property (nonatomic, strong) NSArray <NSString *> *headerValues;

@end

@implementation XXScanDownloadSourceHeadersTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    NSURL *url = [NSURL URLWithString:self.url];
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.f];
    [urlRequest setHTTPMethod:@"HEAD"];
    @weakify(self);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                @strongify(self);
                                                dispatch_async_on_main_queue(^{
                                                    self.navigationController.view.userInteractionEnabled = YES;
                                                    [self.navigationController.view hideToastActivity];
                                                    NSHTTPURLResponse *realResponse = (NSHTTPURLResponse *)response;
                                                    self.headers = realResponse.allHeaderFields;
                                                    self.headerKeys = [self.headers allKeysSorted];
                                                    self.headerValues = [self.headers allValuesSortedByKeys];
                                                    [self.tableView reloadData];
                                                    self.buttonCopy.enabled = YES;
                                                });
                                            }];
    [task resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
        [self.navigationController.view makeToast:NSLocalizedString(@"Copied to the clipboard", nil)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerKeys.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Headers", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kXXScanDownloadSourceHeadersTableViewCellReuseIdentifier forIndexPath:indexPath];
        cell.textLabel.text = self.headerKeys[indexPath.row];
        cell.detailTextLabel.text = self.headerValues[indexPath.row];
        return cell;
    }
    return [UITableViewCell new];
}

- (IBAction)buttonCopyTapped:(id)sender {
    NSString *jsonPrinted = [self.headers jsonPrettyStringEncoded];
    [[UIPasteboard generalPasteboard] setString:jsonPrinted];
    [self.navigationController.view makeToast:NSLocalizedString(@"All header fields have been copied to the clipboard", nil)];
}

@end
