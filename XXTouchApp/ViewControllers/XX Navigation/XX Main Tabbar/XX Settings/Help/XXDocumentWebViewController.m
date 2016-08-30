//
//  XXDocumentWebViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "XXDocumentWebViewController.h"

@interface XXDocumentWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *agreementWebView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIBarButtonItem *shareItem;

@end

@implementation XXDocumentWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"Documents", @"XXTouch", nil);
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _agreementWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    NSURL *url = [NSURL URLWithString:DOCUMENT_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_agreementWebView loadRequest:request];
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openDocumentSafari:) ];
        _shareItem = anotherButton;
    }
    return _shareItem;
}

- (void)openDocumentSafari:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOCUMENT_URL]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    self.navigationItem.rightBarButtonItem = self.shareItem;
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

@end
