//
//  XXBaseTextEditorViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/18/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXBaseTextEditorViewController.h"
#import "XXBaseTextView.h"
#import <Masonry/Masonry.h>

@interface XXBaseTextEditorViewController () <UITextViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *fakeStatusBar;
@property (nonatomic, strong) XXBaseTextView *textView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) NSString *fileContent;
@property (nonatomic, strong) UIToolbar *bottomBar;

@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation XXBaseTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.displayName;
    self.fd_interactivePopDisabled = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSError *err = nil;
    self.fileContent = [FCFileManager readFileAtPath:self.filePath error:&err];
    if (!_fileContent) {
        [self.navigationController.view makeToast:[err localizedDescription]];
    }
    
    [self.view addSubview:self.fakeStatusBar];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.bottomBar];
    
    self.navigationItem.rightBarButtonItem = self.shareItem;
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDismiss:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    NSError *err = nil;
    [FCFileManager writeFileAtPath:self.filePath content:self.textView.text error:&err];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    CGRect frame = CGRectNull;
    if (!self.navigationController.navigationBarHidden) {
        frame = CGRectZero;
    } else {
        frame = [[UIApplication sharedApplication] statusBarFrame];
    }
    [self.fakeStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.width.equalTo(@(frame.size.width));
        make.height.equalTo(@(frame.size.height));
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(44));
    }];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fakeStatusBar.mas_bottom).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

- (UIView *)fakeStatusBar {
    if (!_fakeStatusBar) {
        CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
        UIView *fakeStatusBar = [[UIView alloc] initWithFrame:frame];
        fakeStatusBar.backgroundColor = [UIColor whiteColor];
        _fakeStatusBar = fakeStatusBar;
    }
    return _fakeStatusBar;
}

- (UITextView *)textView {
    if (!_textView) {
        UIFont *font = [UIFont fontWithName:@"Courier New" size:14.0f];
        
        XXBaseTextView *textView = [[XXBaseTextView alloc] initWithFrame:self.view.bounds];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.font = font;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        textView.alwaysBounceVertical = YES;
        textView.delegate = self;
        textView.inputAccessoryView = self.toolBar;
        textView.tintColor = STYLE_TINT_COLOR;
        if (self.fileContent)
            textView.text = self.fileContent;
        textView.selectedRange = NSMakeRange(0, 0);
        textView.contentOffset = CGPointZero;
        textView.contentInset =
        textView.scrollIndicatorInsets =
        UIEdgeInsetsMake(0, 0, self.bottomBar.height, 0);
        
        NSString *fileExt = [self.filePath pathExtension];
        if ([fileExt isEqualToString:@"lua"]) {
            textView.highlightLuaSymbols = YES;
        } else {
            textView.highlightLuaSymbols = NO;
        }
        _textView = textView;
    }
    return _textView;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        /* Elements of tool bar items */
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *myToolBarItems = [NSMutableArray array];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithTitle:XXLString(@"Tab") style:UIBarButtonItemStyleBordered target:self action:@selector(insertTab:)]];
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)]];
        
        /* Init of toolBar */
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        toolBar.barStyle = UIBarStyleDefault;
        [toolBar setTintColor:STYLE_TINT_COLOR];
        [toolBar setItems:myToolBarItems animated:YES];
        _toolBar = toolBar;
    }
    return _toolBar;
}

- (UIToolbar *)bottomBar {
    if (!_bottomBar) {
        UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        bottomBar.tintColor = STYLE_TINT_COLOR;
        _bottomBar = bottomBar;
    }
    return _bottomBar;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openIn:) ];
        anotherButton.tintColor = [UIColor whiteColor];
        _shareItem = anotherButton;
    }
    return _shareItem;
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
}

- (void)openIn:(id)sender {
    self.documentController.URL = [NSURL fileURLWithPath:self.filePath];
    BOOL didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    if (!didPresentOpenIn) {
        [self.navigationController.view makeToast:XXLString(@"Cannot find supporting application")];
    }
}

#pragma mark - Toolbar Actions

- (void)dismissKeyboard:(UIBarButtonItem *)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (void)insertTab:(UIBarButtonItem *)sender {
    if (![self.textView isFirstResponder]) {
        return;
    }
    [self.textView insertText:@"    "];
}

- (void)keyboardWillAppear:(NSNotification *)aNotification {
    NSValue *keyboardRectAsObject = [[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = CGRectNull;
    [keyboardRectAsObject getValue:&keyboardRect];
    self.textView.contentInset =
    self.textView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [self updateViewConstraints];
}

- (void)keyboardWillChangeFrame:(NSNotification *)aNotification {
    
}

- (void)keyboardWillDismiss:(NSNotification *)aNotification {
    self.textView.contentInset =
    self.textView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, self.bottomBar.height, 0);
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self updateViewConstraints];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)dealloc {
    CYLog(@"");
}

@end
