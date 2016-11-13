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

@interface XXTerminalViewController () <UITextViewDelegate, XXLuaVModelDelegate>

@property (nonatomic, strong) XXLuaVModel *virtualModel;
@property (nonatomic, strong) XXTerminalTextView *textView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *refreshItem;
@property (nonatomic, strong) UIBarButtonItem *scrollItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *activityIndicatorItem;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation XXTerminalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = self.closeItem;
    self.navigationItem.rightBarButtonItem = self.activityIndicatorItem;
    [self.view addSubview:self.textView];
    [self.view addSubview:self.toolbar];
    [self updateViewConstraints];
    
    [self loadProcess];
}

- (void)dealloc {
    CYLog(@"");
    [self resetVirtualMachine];
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

- (void)loadProcess {
    [self.textView scrollToTopAnimated:NO];
    [self.textView setText:@""];
    [self displayWelcomeMessage];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(executeScript) withObject:nil afterDelay:.6f];
}

#pragma mark - Getters

- (XXTerminalTextView *)textView {
    if (!_textView) {
        XXTerminalTextView *textView = [[XXTerminalTextView alloc] initWithFrame:self.view.bounds];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.dataDetectorTypes = UIDataDetectorTypeNone;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        textView.alwaysBounceVertical = YES;
        textView.delegate = self;
        textView.scrollIndicatorInsets =
        textView.contentInset = UIEdgeInsetsMake(0, 0, self.toolbar.height, 0);
        _textView = textView;
    }
    return _textView;
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

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemTapped:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator = activityIndicator;
    }
    return _activityIndicator;
}

- (UIBarButtonItem *)activityIndicatorItem {
    if (!_activityIndicatorItem) {
        UIBarButtonItem *activityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        activityIndicatorItem.tintColor = [UIColor whiteColor];
        _activityIndicatorItem = activityIndicatorItem;
    }
    return _activityIndicatorItem;
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

#pragma mark - Redirect

- (void)redirectStd:(int)fd {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading];
    int result = dup2([[pipe fileHandleForWriting] fileDescriptor], fd);
    if (result != -1) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(redirectNotificationHandle:)
                                                     name:NSFileHandleReadCompletionNotification
                                                   object:pipeReadHandle];
        [pipeReadHandle readInBackgroundAndNotify];
    }
}

- (void)redirectNotificationHandle:(NSNotification *)aNotification {
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.textView appendString:str];
    [[aNotification object] readInBackgroundAndNotify];
}

#pragma mark - Execute

- (void)displayWelcomeMessage {
    [self.textView appendMessage:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@LUA_COPYRIGHT, nil)]];
    [self.textView appendMessage:[NSString stringWithFormat:NSLocalizedString(@"\nExecuting %@...\n", nil), self.filePath]];
}

- (void)displayFinishMessage {
    [self.textView appendMessage:NSLocalizedString(@"\n\nRun finished\n", nil)];
}

- (void)launchVirtualMachine {
    [self resetVirtualMachine];
    
    XXLuaVModel *virtualModel = [[XXLuaVModel alloc] init];
    virtualModel.delegate = self;
    [self redirectStd:fileno(virtualModel.stdoutHandler)];
    [self redirectStd:fileno(virtualModel.stderrHandler)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextViewInsetsWithKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextViewInsetsWithKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.virtualModel = virtualModel;
}

- (void)resetVirtualMachine {
    if (self.virtualModel.running) {
        return;
    }
    self.virtualModel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shutdownVirtualMachine {
    [self.virtualModel setRunning:NO];
}

- (void)executeScript {
    [self launchVirtualMachine];
    NSError *err = nil;
    BOOL result = [self.virtualModel loadFileFromPath:self.filePath error:&err];
    if (result == NO && err) {
        [self.textView appendError:[NSString stringWithFormat:@"\n%@\n", [err localizedFailureReason]]];
        return;
    } else {
        [self.textView appendMessage:NSLocalizedString(@"\nSyntax check passed, running...\n\n", nil)];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *err = nil;
        BOOL result = [self.virtualModel pcallWithError:&err];
        dispatch_async_on_main_queue(^{
            if (result == NO && err) {
                [self.textView appendError:[NSString stringWithFormat:@"\n%@", [err localizedFailureReason]]];
                return;
            }
        });
    });
}

#pragma mark - Actions

- (void)refreshItemTapped:(UIBarButtonItem *)sender {
    if (self.virtualModel.running) return;
    self.refreshItem.enabled =
    self.scrollItem.enabled =
    self.closeItem.enabled = NO;
    [self loadProcess];
}

- (void)scrollItemTapped:(UIBarButtonItem *)sender {
    if (self.virtualModel.running) return;
    [self.textView scrollToBottom];
}

- (void)closeItemTapped:(UIBarButtonItem *)sender {
    if (self.virtualModel.running) {
        self.refreshItem.enabled =
        self.scrollItem.enabled =
        self.closeItem.enabled = NO;
        [self shutdownVirtualMachine];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(XXTerminalTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *originalText = textView.text;
    if (
        range.location == originalText.length &&
        range.length == 0 &&
        text.length != 0
        ) {
        if ([text isEqualToString:@"\n"]) {
            [textView insertText:text];
            NSString *bufferedString = [textView getBufferString];
            const char *buf = bufferedString.UTF8String;
            write(fileno(self.virtualModel.stdinWriteHandler), buf, strlen(buf));
            return NO;
        }
        [self.textView resetTypingAttributes];
        return YES;
    }
    else if (
             range.location == originalText.length - 1 &&
             text.length == 0 &&
             [textView canDeleteBackward]
             ) {
        return YES;
    }
    textView.selectedRange = NSMakeRange(textView.text.length, 0);
    return NO;
}

#pragma mark - XXLuaVModelDelegate

- (void)virtualMachineDidChangedState:(XXLuaVModel *)vm {
    dispatch_sync_on_main_queue(^{
        self.closeItem.enabled = YES;
        self.textView.editable = vm.running;
        self.scrollItem.enabled =
        self.refreshItem.enabled = !vm.running;
        if (vm.running == NO) {
            [self.activityIndicator stopAnimating];
            self.closeItem.title = NSLocalizedString(@"Close", nil);
            if ([self.textView isFirstResponder]) {
                [self.textView resignFirstResponder];
            }
            [self performSelector:@selector(displayFinishMessage) withObject:nil afterDelay:.6f];
        } else {
            [self.activityIndicator startAnimating];
            self.closeItem.title = NSLocalizedString(@"Stop", nil);
        }
    });
}

#pragma mark - Keyboard Events

- (void)updateTextViewInsetsWithKeyboardNotification:(NSNotification *)notification
{
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    
    if (notification)
    {
        CGRect keyboardFrame;
        
        [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        
        newInsets.bottom = self.view.frame.size.height - keyboardFrame.origin.y;
    }
    
    if (newInsets.bottom == 0) {
        newInsets.bottom = self.toolbar.frame.size.height;
    }
    
    ICTextView *textView = self.textView;
    textView.contentInset = newInsets;
    textView.scrollIndicatorInsets = newInsets;
}

@end
