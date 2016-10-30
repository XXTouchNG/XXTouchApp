//
//  XXWebViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "XXWebViewController.h"
#import "ARSafariActivity.h"
#import <Masonry/Masonry.h>
#import "XXQuickLookService.h"
#import "NSArray+FindString.h"
#import "NSData+plistData.h"

static NSString * const kXXWebViewErrorDomain = @"kXXWebViewErrorDomain";

@interface XXWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIBarButtonItem *transferItem;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation XXWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self loadWebView];
}

- (void)loadWebView {
    NSData *fileData = nil;
    NSError *err = nil;
    NSString *fileType = [[self.url pathExtension] lowercaseString];
    if ([[[self class] logWebViewFileExtensions] existsString:fileType])
    {
        fileData = [NSData dataWithContentsOfURL:self.url
                                         options:NSDataReadingMappedIfSafe
                                           error:&err];
        self.loadType = kXXWebViewLoadTypePlain;
    }
    else if ([[[self class] plistWebViewFileExtensions] existsString:fileType])
    {
        NSData *tData = [NSData dataWithContentsOfURL:self.url
                                         options:NSDataReadingMappedIfSafe
                                           error:&err];
        if (tData) {
            fileData = [[tData plistString] dataUsingEncoding:NSUTF8StringEncoding];
            if (!fileData) {
                NSString *fileName = [self.url lastPathComponent];
                err = [NSError errorWithDomain:kXXWebViewErrorDomain
                                          code:0
                                      userInfo:@{
                                                 NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:NSLocalizedString(@"Failed to load property list \"%@\"", nil), fileName]}];
            }
        }
        self.loadType = kXXWebViewLoadTypePlist;
    }
    
    if (fileData == nil)
    {
        if (err != nil) {
            [self.navigationController.view makeToast:[err localizedDescription]];
            return;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    else
    {
        [self.webView loadData:fileData
                      MIMEType:@"text/plain"
              textEncodingName:@"UTF-8"
                       baseURL:self.url]; // Text Encoding
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    if ([[UIApplication sharedApplication] canOpenURL:self.url]) {
        self.navigationItem.rightBarButtonItem = self.shareItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.transferItem;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Getters

- (NJKWebViewProgress *)progressProxy {
    if (!_progressProxy) {
        NJKWebViewProgress *progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
        progressProxy.webViewProxyDelegate = self;
        progressProxy.progressDelegate = self;
        _progressProxy = progressProxy;
    }
    return _progressProxy;
}

- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        CGFloat progressBarHeight = 2.f;
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
        NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView = progressView;
    }
    return _progressView;
}

- (UIWebView *)webView {
    if (!_webView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        webView.delegate = self.progressProxy;
        webView.allowsInlineMediaPlayback = YES;
        webView.scalesPageToFit = YES;
        if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
            webView.allowsLinkPreview = YES;
            webView.allowsPictureInPictureMediaPlayback = YES;
        }
        _webView = webView;
    }
    return _webView;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openDocumentSafari:) ];
        anotherButton.tintColor = [UIColor whiteColor];
        anotherButton.enabled = NO;
        _shareItem = anotherButton;
    }
    return _shareItem;
}

- (UIBarButtonItem *)transferItem {
    if (!_transferItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(transferDocument:)];
        anotherButton.tintColor = [UIColor whiteColor];
        anotherButton.enabled = NO;
        _transferItem = anotherButton;
    }
    return _transferItem;
}

#pragma mark - Actions

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openDocumentSafari:(id)sender {
    ARSafariActivity *safariActivity = [[ARSafariActivity alloc] init];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:@[safariActivity]];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)transferDocument:(id)sender {
    self.documentController.URL = self.url;
    BOOL didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    if (!didPresentOpenIn) {
        [self.navigationController.view makeToast:NSLocalizedString(@"No apps available", nil)];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == _webView && _progressView) {
        [_progressView setProgress:0.0 animated:YES];
    }
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && title.length > 0) {
        self.title = title;
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController.view makeToast:[error localizedDescription]];
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

- (void)dealloc {
    CYLog(@"");
}

#pragma mark - File Types

+ (NSArray <NSString *> *)supportedFileType {
    return @[
             @"txt",
             @"log",
             @"syslog",
             @"ips",
             @"html",
             @"htm",
             @"rtf",
             @"doc",
             @"docx",
             @"xls",
             @"xlsx",
             @"pdf",
             @"ppt",
             @"pptx",
             @"pages",
             @"key",
             @"numbers",
             @"svg",
             @"epub",
             @"plist"
             ];
}

+ (NSArray <NSString *> *)logWebViewFileExtensions { // Treat like plain text
    return @[ @"txt", @"log", @"syslog", @"ips", @"strings" ];
}

+ (NSArray <NSString *> *)plistWebViewFileExtensions {
    return @[ @"plist" ];
}

+ (NSArray <NSString *> *)codeWebViewFileExtensions { // Syntax highlighter
    return @[ ];
}

@end
