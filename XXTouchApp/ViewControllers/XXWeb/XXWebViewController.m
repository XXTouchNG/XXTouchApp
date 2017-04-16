//
//  XXWebViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXWebViewController.h"
#import "ARSafariActivity.h"
#import "XXQuickLookService.h"
#import "NSArray+FindString.h"
#import "NSData+PlistData.h"

static NSString * const kXXWebViewErrorDomain = @"kXXWebViewErrorDomain";

@interface XXWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIBarButtonItem *transferItem;
@property (nonatomic, strong, readonly) NSURL *baseUrl;

@property (nonatomic, strong) UIPopoverController *currentPopoverController;
@end

@implementation XXWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    if (self.navigationController.isNavigationBarHidden) {
        return YES;
    }
    return [super prefersStatusBarHidden];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    [self updateViewConstraints];
    [self loadWebView];
}

- (void)loadWebView {
    if (![[self.url scheme] isEqualToString:@"file"])
    { // Not local
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
        self.navigationItem.rightBarButtonItem = self.shareItem;
        return;
    }
    self.navigationItem.rightBarButtonItem = self.transferItem;
    
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Getters

- (NSURL *)baseUrl {
    return [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"XXTReferences.bundle"];
}

- (UIWebView *)webView {
    if (!_webView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        webView.delegate = self;
        webView.allowsInlineMediaPlayback = YES;
        webView.scalesPageToFit = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemTapped:) ];
        shareItem.tintColor = [UIColor whiteColor];
        shareItem.enabled = NO;
        _shareItem = shareItem;
    }
    return _shareItem;
}

- (UIBarButtonItem *)transferItem {
    if (!_transferItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(transferItemTapped:)];
        anotherButton.tintColor = [UIColor whiteColor];
        anotherButton.enabled = NO;
        _transferItem = anotherButton;
    }
    return _transferItem;
}

#pragma mark - Actions

- (IBAction)close:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.activity && !self.activity.activeDirectly) {
            [self.activity activityDidFinish:YES];
        }
    }];
}

- (void)shareItemTapped:(UIBarButtonItem *)sender {
    ARSafariActivity *safariActivity = [[ARSafariActivity alloc] init];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:@[safariActivity]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationPopover;
        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            [popover presentPopoverFromBarButtonItem:sender
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
            self.currentPopoverController = popover;
            popover.delegate = self;
            popover.passthroughViews = nil;
            return;
        }
        controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.popoverPresentationController.barButtonItem = sender;
    }
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)transferItemTapped:(UIBarButtonItem *)sender {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationPopover;
        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            [popover presentPopoverFromBarButtonItem:sender
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
            self.currentPopoverController = popover;
            popover.delegate = self;
            popover.passthroughViews = nil;
            return;
        }
        controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.popoverPresentationController.barButtonItem = sender;
    }
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && title.length > 0) {
        self.title = title;
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController.view makeToast:[error localizedDescription]];
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
             @"html", @"htm",
             @"rtf", @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"ppt", @"pptx",
             @"pages", @"key", @"numbers", @"svg", @"epub",
             ];
}

+ (NSArray <NSString *> *)logWebViewFileExtensions { // Treat like plain text
    return @[ @"txt", @"log", @"syslog", @"ips", @"strings" ];
}

+ (NSArray <NSString *> *)plistWebViewFileExtensions {
    return @[ @"plist" ];
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
