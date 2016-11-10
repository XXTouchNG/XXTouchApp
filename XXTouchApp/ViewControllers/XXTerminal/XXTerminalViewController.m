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
@property (nonatomic, strong) UIBarButtonItem *refreshBtn;
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
    
    self.navigationItem.rightBarButtonItem = self.refreshBtn;
    
    XXTerminalTextView *textView = [[XXTerminalTextView alloc] initWithFrame:self.view.bounds];
    textView.delegate = self;
    self.textView = textView;
    [self.view addSubview:self.textView];
    [self updateViewConstraints];
    
    [self reloadView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Load

- (void)reloadView {
    self.textView.text = @"";
    [self displayWelcomeMessage];
    
    if (!self.isRunning) {
        self.isRunning = YES;
        [self performSelector:@selector(executeScript) withObject:nil afterDelay:.6f];
    }
}

#pragma mark - Getters

- (UIBarButtonItem *)refreshBtn {
    if (!_refreshBtn) {
        UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadView)];
        refreshBtn.enabled = NO;
        refreshBtn.tintColor = [UIColor whiteColor];
        _refreshBtn = refreshBtn;
    }
    return _refreshBtn;
}

#pragma mark - Setters

- (void)setIsRunning:(BOOL)isRunning {
    _isRunning = isRunning;
    self.refreshBtn.enabled = !isRunning;
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
    [self.textView appendMessage:[NSString stringWithFormat:NSLocalizedString(@"Executing %@...", nil), self.filePath]];
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

@end
