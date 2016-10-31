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
@property (nonatomic, strong, readonly) NSURL *baseUrl;

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
    if (![[self.url scheme] isEqualToString:@"file"])
    { // Not local
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
        return;
    }
    NSData *fileData = nil;
    NSString *fileString = nil;
    NSError *err = nil;
    NSString *fileName = [self.url lastPathComponent];
    NSString *fileType = [[self.url pathExtension] lowercaseString];
    if ([[[self class] documentWebViewFileExtensions] existsString:fileType]) // Trans to plist
    {
        self.loadType = kXXWebViewLoadTypeCommon;
    }
    else if ([[[self class] logWebViewFileExtensions] existsString:fileType]) // Only plain text
    {
        fileData = [NSData dataWithContentsOfURL:self.url
                                         options:NSDataReadingMappedIfSafe
                                           error:&err];
        self.loadType = kXXWebViewLoadTypePlain;
    } else if ([[[self class] plistWebViewFileExtensions] existsString:fileType]) // Trans to plist
    {
        NSData *tData = [NSData dataWithContentsOfURL:self.url
                                              options:NSDataReadingMappedIfSafe
                                                error:&err];
        if (tData) {
            fileString = [tData plistString];
            if (!fileString) {
                err = [NSError errorWithDomain:kXXWebViewErrorDomain
                                          code:0
                                      userInfo:@{
                                                 NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:NSLocalizedString(@"Failed to load property list \"%@\"", nil), fileName]}];
            }
        }
        self.loadType = kXXWebViewLoadTypePlist;
    } else {
        self.loadType = kXXWebViewLoadTypeCode;
    }
    
    if (self.loadType == kXXWebViewLoadTypePlist ||
        self.loadType == kXXWebViewLoadTypeCode) // Code Highlight
    {
        NSString *htmlTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"XXTReferences.bundle/code" ofType:@"html"]
                                                           encoding:NSUTF8StringEncoding
                                                              error:&err];
        if (err == nil) {
            NSString *originalString = nil;
            if (fileData) {
                originalString = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] stringByEscapingHTML];
                fileData = nil;
            } else if (fileString) {
                // Nothing to do
            } else {
                fileString = [NSString stringWithContentsOfURL:self.url
                                                      encoding:NSUTF8StringEncoding
                                                         error:&err];
            }
            if (fileString) {
                originalString = [fileString stringByEscapingHTML];
                fileString = nil;
            }
            if (err == nil) {
                htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"{{ title }}" withString:fileName];
                htmlTemplate = [htmlTemplate stringByReplacingOccurrencesOfString:@"{{ code }}" withString:originalString];
                fileString = htmlTemplate;
            }
        }
    }
    
    if (fileData != nil)
    {
        [self.webView loadData:fileData
                      MIMEType:@"text/plain"
              textEncodingName:@"UTF-8"
                       baseURL:self.baseUrl]; // Text Encoding
    }
    else if (fileString != nil)
    {
        [self.webView loadHTMLString:fileString
                             baseURL:self.baseUrl];
    }
    else
    {
        if (err != nil) {
            [self.navigationController.view makeToast:[err localizedDescription]];
            return;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
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

- (NSURL *)baseUrl {
    return [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"XXTReferences.bundle"];
}

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
    NSMutableArray *supportedFileType = [NSMutableArray new];
    [supportedFileType addObjectsFromArray:[self documentWebViewFileExtensions]];
    [supportedFileType addObjectsFromArray:[self logWebViewFileExtensions]];
    [supportedFileType addObjectsFromArray:[self plistWebViewFileExtensions]];
    return [supportedFileType copy];
}

+ (NSArray <NSString *> *)documentWebViewFileExtensions {
    return @[
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
             ];
}

+ (NSArray <NSString *> *)logWebViewFileExtensions { // Treat like plain text
    return @[ @"txt", @"log", @"syslog", @"ips", @"strings" ];
}

+ (NSArray <NSString *> *)plistWebViewFileExtensions {
    return @[ @"plist" ];
}

@end
