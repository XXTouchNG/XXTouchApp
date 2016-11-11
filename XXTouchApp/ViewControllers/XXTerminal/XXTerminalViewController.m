//
//  XXTerminalViewController.m
//  XXTouchApp
//
//  Created by Zheng on 10/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLuaVModel.h"
#import "XXTerminalViewController.h"
#import "XXTerminalTextView.h"
#import "XXLocalDataService.h"
#import <Masonry/Masonry.h>

@interface XXTerminalViewController () <UITextViewDelegate>

@property (nonatomic, strong) XXLuaVModel *virtualModel;
@property (nonatomic, strong) XXTerminalTextView *textView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIBarButtonItem *refreshItem;
@property (nonatomic, strong) UIBarButtonItem *scrollItem;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, assign) BOOL isRunning;

@end

@implementation XXTerminalViewController

- (instancetype)init {
    if (self = [super init]) {
        self.virtualModel = [[XXLuaVModel alloc] init];
        
        [self redirectStd:fileno([[XXLocalDataService sharedInstance] stderrHandler])];
        [self redirectStd:fileno([[XXLocalDataService sharedInstance] stdoutHandler])];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = self.shareItem;
    [self.view addSubview:self.textView];
    [self.view addSubview:self.toolbar];
    [self updateViewConstraints];
    
    [self reloadView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.toolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
}

#pragma mark - Load

- (void)reloadView {
    [self.textView scrollToTopAnimated:NO];
    [self.textView setText:@""];
    [self displayWelcomeMessage];
    
    if (!self.isRunning) {
        self.isRunning = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(executeScript) withObject:nil afterDelay:.6f];
    }
}

#pragma mark - Getters

- (XXTerminalTextView *)textView {
    if (!_textView) {
        XXTerminalTextView *textView = [[XXTerminalTextView alloc] initWithFrame:self.view.bounds];
        textView.delegate = self;
        textView.scrollIndicatorInsets =
        textView.contentInset = UIEdgeInsetsMake(0, 0, self.toolbar.height, 0);
        _textView = textView;
    }
    return _textView;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemTapped:) ];
        shareItem.enabled = NO;
        shareItem.tintColor = [UIColor whiteColor];
        _shareItem = shareItem;
    }
    return _shareItem;
}

- (UIBarButtonItem *)refreshItem {
    if (!_refreshItem) {
        UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshItemTapped:)];
        refreshItem.enabled = NO;
        refreshItem.tintColor = STYLE_TINT_COLOR;
        _refreshItem = refreshItem;
    }
    return _refreshItem;
}

- (UIBarButtonItem *)scrollItem {
    if (!_scrollItem) {
        UIBarButtonItem *scrollItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scroll-bottom"] style:UIBarButtonItemStylePlain target:self action:@selector(scrollItemTapped:)];
        scrollItem.enabled = NO;
        scrollItem.tintColor = STYLE_TINT_COLOR;
        _scrollItem = scrollItem;
    }
    return _scrollItem;
}

- (UIToolbar *)toolbar {
    if (!_toolbar) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolbar setItems:@[self.refreshItem, flexibleSpace, self.scrollItem]];
        _toolbar = toolbar;
    }
    return _toolbar;
}

#pragma mark - Setters

- (void)setIsRunning:(BOOL)isRunning {
    _isRunning = isRunning;
    self.scrollItem.enabled =
    self.refreshItem.enabled =
    self.shareItem.enabled = !isRunning;
}

#pragma mark - Redirect

- (void)redirectStd:(int)fd {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    int result = dup2([[pipe fileHandleForWriting] fileDescriptor], fd);
    if (result != -1) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(redirectNotificationHandle:)
                                                     name:NSFileHandleReadCompletionNotification
                                                   object:pipeReadHandle] ;
        [pipeReadHandle readInBackgroundAndNotify];
    }
}

- (void)redirectNotificationHandle:(NSNotification *)aNotification {
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.textView appendLine:[str substringToIndex:str.length - 1]];
    
    [[aNotification object] readInBackgroundAndNotify];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(XXTerminalTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *originalText = textView.text;
    if (
        range.location == originalText.length &&
        range.length == 0 &&
        text.length != 0
        ) {
        return YES;
    }
    else if (
             range.location == originalText.length - 1 &&
             text.length == 0 &&
             [textView canDeleteBackward]
             ) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Execute

- (void)displayWelcomeMessage {
    [self.textView appendMessage:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@LUA_COPYRIGHT, nil)]];
    [self.textView appendMessage:[NSString stringWithFormat:NSLocalizedString(@"Executing %@...\n", nil), self.filePath]];
}

- (void)executeScript {
    NSError *err = nil;
    BOOL result = [self.virtualModel loadFileFromPath:self.filePath error:&err];
    if (result == NO && err) {
        [self.textView appendError:[err localizedFailureReason]];
        self.textView.editable = NO;
        self.isRunning = NO;
        return;
    } else {
        [self.textView appendMessage:NSLocalizedString(@"Syntax check passed, running...\n", nil)];
    }
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *err = nil;
        BOOL result = [self.virtualModel pcallWithError:&err];
        dispatch_async_on_main_queue(^{
            self.isRunning = NO;
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (result == NO && err) {
                [self.textView appendError:[err localizedFailureReason]];
                return;
            }
        });
    });
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
}

#pragma mark - Actions

- (void)shareItemTapped:(id)sender {
    if (self.isRunning) return;
    self.documentController.URL = [NSURL fileURLWithPath:self.filePath];
    BOOL didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    if (!didPresentOpenIn) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot find supporting application", nil)];
    }
}

- (void)refreshItemTapped:(UIBarButtonItem *)sender {
    if (self.isRunning) return;
    [self reloadView];
}

- (void)scrollItemTapped:(UIBarButtonItem *)sender {
    if (self.isRunning) return;
    [self.textView scrollToBottom];
}

@end
