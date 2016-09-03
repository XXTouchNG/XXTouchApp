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
#import <Social/Social.h>

@interface XXWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, strong) UIWebView *agreementWebView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIBarButtonItem *shareItem;

@end

@implementation XXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.agreementWebView];
    [self.agreementWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (NSURL *)url {
    if (!_url) {
        _url = [NSURL URLWithString:OFFICIAL_SITE];
    }
    return _url;
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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.agreementWebView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateViewConstraints];
}

- (UIWebView *)agreementWebView {
    if (!_agreementWebView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        webView.delegate = self.progressProxy;
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [webView loadRequest:request];
        _agreementWebView = webView;
    }
    return _agreementWebView;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openDocumentSafari:) ];
        _shareItem = anotherButton;
    }
    return _shareItem;
}

- (void)openDocumentSafari:(id)sender {
    ARSafariActivity *safariActivity = [[ARSafariActivity alloc] init];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:@[safariActivity ]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    if ([[UIApplication sharedApplication] canOpenURL:self.url]) {
        self.navigationItem.rightBarButtonItem = self.shareItem;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == _agreementWebView && _progressView) {
        [_progressView setProgress:0.0 animated:YES];
    }
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

- (void)dealloc {
    CYLog(@"");
}

@end
