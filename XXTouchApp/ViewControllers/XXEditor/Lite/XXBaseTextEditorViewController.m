//
//  XXBaseTextEditorViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/18/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#define GENERATE_ERROR(m) (*err = [NSError errorWithDomain:kXXErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey:m }])

#import "XXBaseTextEditorViewController.h"
#import "XXBaseTextEditorPropertiesTableViewController.h"
#import "XXEditorSettingsTableViewController.h"
#import "XXCodeBlockNavigationController.h"
#import "XXCodeBlocksViewController.h"
#import "XXBaseTextView.h"
#import "XXSearchBar.h"
#import "XXLocalNetService.h"
#import "XXLocalDataService.h"
#import <Masonry/Masonry.h>
#import "XXKeyboardRow.h"
#import "XXLuaVModel.h"
#import "XXTerminalActivity.h"
#import "XXPaymentActivity.h"
#import "NSFileManager+Size.h"

static NSString * const kXXErrorDomain = @"com.xxtouch.error-domain";

@interface XXBaseTextEditorViewController ()
<UITextViewDelegate,
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
UISearchBarDelegate,
XXEditorSettingsTableViewControllerDelegate>

@property (nonatomic, strong) UIView *fakeStatusBar;
@property (nonatomic, strong) XXBaseTextView *textView;
@property (nonatomic, copy) NSString *fileContent;
@property (nonatomic, strong) UIToolbar *bottomBar;

@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIBarButtonItem *launchItem;
@property (nonatomic, strong) UIButton *readingItem;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, assign) BOOL isLuaCode;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, assign) BOOL shouldReloadSection;
@property (nonatomic, strong) NSMutableArray <NSNumber *> *reloadSectionArr;

// Search
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, strong) XXSearchBar *searchBar;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIToolbar *searchToolBar;

// Configure
@property (nonatomic, strong) XXKeyboardRow *keyboardRow;
@property (nonatomic, copy) NSString *tabString;
@property (nonatomic, assign) BOOL autoIndent;

@end

@implementation XXBaseTextEditorViewController

#pragma mark - View & Constraints

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    NSString *fileExt = [[self.filePath pathExtension] lowercaseString];
    self.isLuaCode = [fileExt isEqualToString:@"lua"];
    self.navigationItem.leftBarButtonItem = self.closeItem;
    if (self.isLuaCode == YES && daemonInstalled() == NO) {
        self.navigationItem.rightBarButtonItem = self.launchItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.shareItem;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.fd_interactivePopDisabled = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.reloadSectionArr = [NSMutableArray new];
    [self.view addSubview:self.fakeStatusBar];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.searchBar];
    [self updateCountLabel];
    [self updateViewConstraints];
    [self updateTextViewInsetsWithKeyboardNotification:nil];
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        [self loadEditorSettings];
        BOOL result = [self loadFileWithError:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                self.isLoaded = NO;
                self.bottomBar.hidden = YES;
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                self.isLoaded = YES;
                self.bottomBar.hidden = NO;
            }
        });
    });
}

- (BOOL)loadFileWithError:(NSError **)err {
    NSNumber *fileSize = [[NSFileManager defaultManager] sizeOfItemAtPath:self.filePath error:err];
    if (*err) return NO;
    NSUInteger fileSizeU = [fileSize unsignedIntegerValue];
    if (fileSizeU > 1024000) {
        GENERATE_ERROR(([NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" is too large to fit in the memory", nil), [self.filePath lastPathComponent]]));
        return NO;
    }
    self.fileContent = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:err];
    if (*err) return NO;
    dispatch_async_on_main_queue(^{
        self.textView.text = self.fileContent;
    });
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDismiss:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDismiss:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.shouldReloadSection) [self reloadEditorSettings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    CGRect frame = CGRectNull;
    if (!self.navigationController.navigationBarHidden) frame = CGRectZero;
    else frame = [[UIApplication sharedApplication] statusBarFrame];
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

#pragma mark - File Handler

- (BOOL)saveFileWithError:(NSError **)err {
    self.fileContent = self.textView.text;
    if (_isLoaded && _isEdited)
        [self.fileContent writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:err];
    return *err == nil;
}

#pragma mark - Setters

- (void)setIsLoaded:(BOOL)isLoaded {
    _isLoaded = isLoaded;
    self.textView.userInteractionEnabled = isLoaded;
    self.shareItem.enabled = isLoaded;
    self.launchItem.enabled = isLoaded && self.isLuaCode;
}

#pragma mark - Getters

- (XXSearchBar *)searchBar {
    if (!_searchBar) {
        CGRect viewBounds = self.view.bounds;
        CGRect searchBarFrame = viewBounds;
        searchBarFrame.size.height = 44.f;
        
        XXSearchBar *searchBar = [[XXSearchBar alloc] initWithFrame:searchBarFrame];
        searchBar.delegate = self;
        searchBar.hidden = YES;
        searchBarFrame = searchBar.frame;
        searchBarFrame.origin.y = -searchBar.frame.size.height;
        searchBar.frame = searchBarFrame;
        
        CGRect toolBarFrame = viewBounds;
        toolBarFrame.size.height = 44.0f;
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchToolBar = toolBar;
        
        UIBarButtonItem *prevButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-left-arrow"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchPreviousMatch)];
        prevButtonItem.tintColor = STYLE_TINT_COLOR;
        UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-right-arrow"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchNextMatch)];
        nextButtonItem.tintColor = STYLE_TINT_COLOR;
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.textColor = [UIColor grayColor];
        _countLabel = countLabel;
        
        UIBarButtonItem *counter = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
        [toolBar setItems:@[prevButtonItem, nextButtonItem, flexibleSpace, counter]];
        
        [searchBar setInputAccessoryView:toolBar];
        _searchBar = searchBar;
    }
    return _searchBar;
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
        XXBaseTextView *textView = [[XXBaseTextView alloc] initWithFrame:self.view.bounds
                                                      lineNumbersEnabled:[[XXLocalDataService sharedInstance] lineNumbersEnabled]];
        textView.delegate = self;
        textView.contentInset =
        textView.scrollIndicatorInsets =
        UIEdgeInsetsMake(0, 0, self.bottomBar.height, 0);
        _textView = textView;
    }
    return _textView;
}

- (UIToolbar *)bottomBar {
    if (!_bottomBar) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *myToolBarItems = [NSMutableArray array];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-search"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)]];
        [myToolBarItems addObject:flexibleSpace];
        
        UIButton *readingItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
        [readingItem setImage:[[UIImage imageNamed:@"toolbar-reading"] imageByTintColor:STYLE_TINT_COLOR]
                     forState:UIControlStateNormal];
        [readingItem setImage:[UIImage imageNamed:@"toolbar-reading"]
                     forState:UIControlStateSelected];
        [readingItem setTarget:self
                        action:@selector(tapUpReadingItem:)
              forControlEvents:UIControlEventTouchUpInside];
        readingItem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(extendGestureRecognized:)];
        longGesture.minimumPressDuration = 1.f;
        longGesture.allowableMovement = 64.f;
        longGesture.enabled = YES;
        longGesture.delegate = self;
        [readingItem addGestureRecognizer:longGesture];
        _readingItem = readingItem;
        
        UIBarButtonItem *readingBarItem = [[UIBarButtonItem alloc] initWithCustomView:readingItem];
        [myToolBarItems addObject:readingBarItem];
        
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-statistics"] style:UIBarButtonItemStylePlain target:self action:@selector(statistics:)]];
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settings:)]];
        
        UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        bottomBar.barStyle = UIBarStyleDefault;
        [bottomBar setTintColor:STYLE_TINT_COLOR];
        [bottomBar setItems:myToolBarItems animated:YES];
        
        _bottomBar = bottomBar;
    }
    return _bottomBar;
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

- (UIBarButtonItem *)launchItem {
    if (!_launchItem) {
        UIBarButtonItem *launchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(launchItemTapped:) ];
        launchItem.tintColor = [UIColor whiteColor];
        launchItem.enabled = NO;
        _launchItem = launchItem;
    }
    return _launchItem;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemTapped:)];
        closeItem.tintColor = [UIColor whiteColor];
        _closeItem = closeItem;
    }
    return _closeItem;
}

- (XXKeyboardRow *)keyboardRow {
    if (!_keyboardRow) {
        XXKeyboardRow *keyboardRow = [[XXKeyboardRow alloc] initWithTextView:self.textView];
        _keyboardRow = keyboardRow;
    }
    return _keyboardRow;
}

#pragma mark - XXSearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(XXSearchBar *)searchBar {
    return YES;
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
}

- (void)shareItemTapped:(UIBarButtonItem *)sender {
    self.documentController.URL = [NSURL fileURLWithPath:self.filePath];
    BOOL didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    if (!didPresentOpenIn) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot find supporting application", nil)];
    }
}

- (void)launchItemTapped:(UIBarButtonItem *)sender {
    if ([[XXLocalDataService sharedInstance] purchasedProduct]) {
        XXTerminalActivity *act = [[XXTerminalActivity alloc] init];
        [act setFileURL:[NSURL fileURLWithPath:self.filePath]];
        [act performActivityWithController:self];
    } else {
        XXPaymentActivity *act = [[XXPaymentActivity alloc] init];
        [act performActivityWithController:self];
    }
}

- (void)closeItemTapped:(UIBarButtonItem *)sender {
    if (self.activity && self.activity.activeDirectly == NO) {
        [self.activity activityDidFinish:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Toolbar Actions

- (void)search:(UIBarButtonItem *)sender {
    self.searchMode = !self.searchMode;
    [self updateSearchBarFrameAnimated:YES];
}

- (void)reading:(UIButton *)sender {
    if (!self.isLuaCode) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Unsupported file type", nil)];
        return;
    }
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        XXLuaVModel *lMachine = [[XXLuaVModel alloc] init];
        BOOL result = [lMachine loadBufferFromString:self.fileContent error:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                NSString *reason = [err localizedFailureReason];
                if (reason) {
                    [self.navigationController.view makeToast:reason];
                    [self scrollToLineByReason:reason];
                }
                if (sender.selected) {
                    [self extendHisLife:YES];
                }
            } else {
                if (err.code == 0) {
                    if (sender.selected) {
                        NSString *myStr = [NSString stringWithBase64EncodedString:[[XXLocalDataService sharedInstance] randString]];
                        [self.navigationController.view makeToast:myStr];
                        [self extendHisLife:NO];
                    } else {
                        [self.navigationController.view makeToast:NSLocalizedString(@"Syntax Check Passed", nil)];
                    }
                }
            }
        });
    });
}

- (void)tapUpReadingItem:(UIButton *)sender {
    [self reading:sender];
}

- (void)extendGestureRecognized:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIButton *button = ((UIButton *)sender.view);
        button.selected = !button.selected;
        if (button.selected) {
            [self.navigationController.view makeToast:NSLocalizedString(@"Stay young, stay naive!", nil)];
        } else {
            [self.navigationController.view makeToast:NSLocalizedString(@"Excited!", nil)];
        }
    }
}

- (void)extendHisLife:(BOOL)fail {
    UIButton *barButtonView = self.readingItem;
    UILabel *addLabel = [[UILabel alloc] init];
    if (fail) {
        addLabel.text = NSLocalizedString(@"-1s", nil);
        addLabel.textColor = [UIColor greenColor];
    } else {
        addLabel.text = NSLocalizedString(@"+1s", nil);
        addLabel.textColor = [UIColor redColor];
    }
    addLabel.font = [UIFont boldSystemFontOfSize:12.f];
    [addLabel sizeToFit];
    addLabel.center = CGPointMake(barButtonView.bounds.size.width / 2, barButtonView.bounds.size.height / 2);
    [barButtonView addSubview:addLabel];
    
    [UIView animateWithDuration:.8f delay:.2f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         addLabel.alpha = 0;
                         addLabel.centerY = -barButtonView.bounds.size.height;
                     } completion:^(BOOL finished) {
                         [addLabel removeFromSuperview];
                     }];
}

- (void)scrollToLineByReason:(NSString *)reason {
    NSArray <NSString *> *arr = [reason componentsSeparatedByString:@":"];
    if (arr.count < 2) return;
    NSUInteger lineRange = [arr[1] unsignedIntegerValue] - 1;
    NSString *s = self.fileContent;
    NSUInteger index = 0;
    NSUInteger count = 0;
    NSUInteger l = [s length];
    for (int i = 0; i < l; i++) {
        char cc = (char) [s characterAtIndex:i];
        if (cc == '\n') {
            count++;
            if (count == lineRange) {
                index = (NSUInteger)i;
                break;
            }
        }
    }
    [self.textView scrollRangeToVisible:NSMakeRange(index, 0) consideringInsets:YES animated:YES];
}

- (void)statistics:(UIBarButtonItem *)sender {
    XXBaseTextEditorPropertiesTableViewController *propertiesController = [STORYBOARD instantiateViewControllerWithIdentifier:kXXBaseTextEditorPropertiesTableViewControllerStoryboardID];
    propertiesController.filePath = self.filePath;
    propertiesController.fileContent = self.fileContent;
    [self.navigationController pushViewController:propertiesController animated:YES];
}

- (void)settings:(UIBarButtonItem *)sender {
    if ([[XXLocalDataService sharedInstance] purchasedProduct]) {
        XXEditorSettingsTableViewController *settingsController = [STORYBOARD instantiateViewControllerWithIdentifier:kXXEditorSettingsTableViewControllerStoryboardID];
        settingsController.delegate = self;
        [self.navigationController pushViewController:settingsController animated:YES];
    } else {
        XXPaymentActivity *act = [[XXPaymentActivity alloc] init];
        [act performActivityWithController:self];
    }
}

#pragma mark - Keyboard Events

- (void)updateTextViewInsetsWithKeyboardNotification:(NSNotification *)notification
{
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    if (self.searchMode) {
        newInsets.top = self.searchBar.frame.size.height;
    }
    newInsets.bottom = self.bottomBar.frame.size.height;
    
    if (notification)
    {
        CGRect keyboardFrame;
        
        [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        
        newInsets.bottom = self.view.frame.size.height - keyboardFrame.origin.y;
    }
    
    ICTextView *textView = self.textView;
    textView.contentInset = newInsets;
    textView.scrollIndicatorInsets = newInsets;
}

- (void)showKeyboard {
    if (![self.textView isFirstResponder]) {
        [self.textView becomeFirstResponder];
    }
}

- (void)keyboardWillAppear:(NSNotification *)aNotification {
    if (!self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [self updateViewConstraints];
    [self updateSearchBarFrameAnimated:YES];
    [self updateTextViewInsetsWithKeyboardNotification:aNotification];
}

- (void)keyboardWillDismiss:(NSNotification *)aNotification {
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [self updateViewConstraints];
    [self updateSearchBarFrameAnimated:YES];
    [self updateTextViewInsetsWithKeyboardNotification:nil];
}

- (void)keyboardDidDismiss:(NSNotification *)aNotification {
    if (!_isEdited) _isEdited = YES;
    NSError *err = nil;
    [self saveFileWithError:&err];
    if (err) {
        [self.navigationController.view makeToast:[err localizedDescription]];
    }
}

#pragma mark - XXSearchBarDelegate

- (void)searchBarTextDidBeginEditing:(XXSearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(XXSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchNextMatch];
}

- (void)searchBarTextDidEndEditing:(XXSearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(XXSearchBar *)searchBar
{
    [self searchNextMatch];
}

- (void)searchBarCancelButtonClicked:(XXSearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - Search Bar Display

- (void)updateSearchBarFrameAnimated:(BOOL)animated {
    __block CGRect searchBarFrame = self.searchBar.frame;
    if (self.searchMode) {
        self.searchBar.hidden = NO;
        searchBarFrame.origin.y = [self.navigationController isNavigationBarHidden] ? [[UIApplication sharedApplication] statusBarFrame].size.height : 0;
    } else {
        searchBarFrame.origin.y = -searchBarFrame.size.height;
    }
    if (animated) {
        [UIView animateWithDuration:.2f delay:.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.searchBar.frame = searchBarFrame;
            [self updateTextViewInsetsWithKeyboardNotification:nil];
        } completion:^(BOOL finished) {
            if (self.searchMode == NO) {
                self.searchBar.hidden = YES;
            }
        }];
    } else {
        self.searchBar.frame = searchBarFrame;
        [self updateTextViewInsetsWithKeyboardNotification:nil];
        if (self.searchMode == NO) {
            self.searchBar.hidden = YES;
        }
    }
}

#pragma mark - ICTextView

- (void)searchNextMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionForward];
}

- (void)searchPreviousMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionBackward];
}

- (void)searchMatchInDirection:(ICTextViewSearchDirection)direction
{
    NSString *searchString = self.searchBar.text;
    
    if (searchString.length) {
        if ([[XXLocalDataService sharedInstance] regexSearchingEnabled]) {
            [self.textView scrollToMatch:searchString searchDirection:direction];
        } else {
            [self.textView scrollToString:searchString searchDirection:direction];
        }
    } else {
        [self.textView resetSearch];
    }
    
    [self updateCountLabel];
}

- (void)updateCountLabel
{
    ICTextView *textView = self.textView;
    UILabel *countLabel = self.countLabel;
    
    NSUInteger numberOfMatches = textView.numberOfMatches;
    countLabel.text = numberOfMatches ? [NSString stringWithFormat:NSLocalizedString(@"%lu/%lu", nil), (unsigned long)textView.indexOfFoundString + 1, (unsigned long)numberOfMatches] : NSLocalizedString(@"0/0", nil);
    [countLabel sizeToFit];
}

#pragma mark - Load Settings

- (void)loadEditorSettings {
    [self loadKeyboardSettings];
    [self loadTabSettings];
    [self loadFontSettings];
    [self loadSearchSettings];
}

- (void)loadSearchSettings {
    self.textView.circularSearch = YES;
    self.textView.scrollPosition = ICTextViewScrollPositionTop;
    self.textView.searchOptions = [[XXLocalDataService sharedInstance] caseSensitiveEnabled] ? 0 : NSRegularExpressionCaseInsensitive;
}

- (void)loadKeyboardSettings {
    self.textView.autocorrectionType = [[XXLocalDataService sharedInstance] autoCorrectionEnabled] ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = [[XXLocalDataService sharedInstance] autoCapitalizationEnabled] ? UITextAutocapitalizationTypeWords : UITextAutocapitalizationTypeNone;
    
    self.textView.editable = ![[XXLocalDataService sharedInstance] readOnlyEnabled];
    dispatch_async_on_main_queue(^{
        if (self.isLuaCode && self.textView.editable) {
            if (self.textView.inputAccessoryView == nil)
            {
                self.textView.inputAccessoryView = self.keyboardRow;
            }
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *codeBlocksItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Code Snippets", nil) action:@selector(menuActionCodeBlocks:)];
            UIMenuItem *shiftLeftItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Shift Left", nil) action:@selector(menuActionShiftLeft:)];
            UIMenuItem *shiftRightItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Shift Right", nil) action:@selector(menuActionShiftRight:)];
            UIMenuItem *commentItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"(Un)Comment", nil) action:@selector(menuActionComment:)];
            [menuController setMenuItems:@[codeBlocksItem, commentItem, shiftLeftItem, shiftRightItem]];
        } else {
            self.textView.inputAccessoryView = nil;
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            [menuController setMenuItems:nil];
        }
    });
}

- (void)loadTabSettings {
    NSString *tabString = nil;
    if ([[XXLocalDataService sharedInstance] softTabsEnabled]) {
        NSArray <NSString *> *tabStringChoices = @[ @"  ", @"   ", @"    ", @"        " ];
        NSUInteger choice = [[XXLocalDataService sharedInstance] tabWidth];
        if (choice < tabStringChoices.count) {
            tabString = tabStringChoices[choice];
        }
    } else {
        tabString = @"\t";
    }
    self.tabString = tabString;
    self.autoIndent = [[XXLocalDataService sharedInstance] autoIndentEnabled];
    dispatch_async_on_main_queue(^{
        [self.keyboardRow setTabString:tabString];
    });
}

- (void)loadFontSettings {
    dispatch_async_on_main_queue(^{
        NSArray <UIFont *> *fontFamily = [[XXLocalDataService sharedInstance] fontFamilyArray];
        NSAssert(fontFamily.count == 3, @"Invalid Font Family");
        [self.textView setDefaultFont:fontFamily[0] shouldUpdate:NO];
        [self.textView setBoldFont:fontFamily[1]];
        [self.textView setItalicFont:fontFamily[2]];
        [self.textView setHighlightLuaSymbols:self.isLuaCode];
    });
}

- (void)loadLineNumberSettings {
    dispatch_async_on_main_queue(^{
        self.textView = nil;
        self.keyboardRow = nil;
        [self.view removeAllSubviews];
        [self viewDidLoad];
    });
}

- (void)reloadEditorSettings {
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSNumber *reloadSection in self.reloadSectionArr) {
            switch ([reloadSection unsignedIntegerValue]) {
                case 0: [self loadFontSettings]; break;
                case 1: [self loadLineNumberSettings]; break;
                case 2: [self loadTabSettings]; break;
                case 3: [self loadKeyboardSettings]; break;
                case 4: [self loadSearchSettings]; break;
                default: break;
            }
        }
        [self.reloadSectionArr removeAllObjects];
        self.shouldReloadSection = NO;
        dispatch_async_on_main_queue(^{
            [self.navigationController.view hideToastActivity];
        });
    });
}

- (void)editorSettingsDidEdited:(XXEditorSettingsTableViewController *)controller
                      inSection:(NSUInteger)section {
    for (NSNumber *reloadSection in self.reloadSectionArr) {
        if ([reloadSection unsignedIntegerValue] == section) {
            return;
        }
    }
    self.shouldReloadSection = YES;
    [self.reloadSectionArr addObject:@(section)];
}

#pragma mark - Menu Actions

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(menuActionComment:) ||
        action == @selector(menuActionShiftLeft:) ||
        action == @selector(menuActionShiftRight:)
        ) {
        NSRange selectedRange = [self.textView selectedRange];
        if (selectedRange.length == 0) {
            return NO;
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)menuActionCodeBlocks:(UIMenuItem *)sender {
    if (self.textView.isEditable == NO) {
        [self.navigationController.view makeToast:NSLocalizedString(@"This document is read-only", nil)];
        return;
    }
    if ([[XXLocalDataService sharedInstance] purchasedProduct]) {
        [self keyboardWillDismiss:nil];
        if ([_textView isFirstResponder]) {
            [_textView resignFirstResponder];
        }
        [self keyboardDidDismiss:nil];
        XXCodeBlockNavigationController *navController = [STORYBOARD instantiateViewControllerWithIdentifier:kXXCodeBlocksTableViewControllerStoryboardID];
        XXCodeBlocksViewController *codeBlocksController = (XXCodeBlocksViewController *)navController.topViewController;
        codeBlocksController.textInput = self.textView;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        XXPaymentActivity *act = [[XXPaymentActivity alloc] init];
        [act performActivityWithController:self];
    }
}

- (NSRange)fixedSelectedTextRange {
    NSRange selectedRange = [self.textView selectedRange];
    NSString *stringRef = self.textView.text;
    NSRange prevBreak = [stringRef rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, selectedRange.location)];
    if (prevBreak.location == NSNotFound)
    {
        prevBreak = NSMakeRange(0, 0);
    }
    return NSMakeRange(prevBreak.location + prevBreak.length,
                       selectedRange.location + selectedRange.length - prevBreak.location - prevBreak.length);
}

- (UITextRange *)textRangeFromNSRange:(NSRange)range {
    UITextPosition *startPosition = [self.textView positionFromPosition:self.textView.beginningOfDocument offset:(NSInteger)range.location];
    UITextPosition *endPosition = [self.textView positionFromPosition:startPosition offset:(NSInteger)range.length];
    UITextRange *textRange = [self.textView textRangeFromPosition:startPosition toPosition:endPosition];
    return textRange;
}

- (void)menuActionShiftLeft:(UIMenuItem *)sender {
    NSRange fixedRange = [self fixedSelectedTextRange];
    NSString *selectedText = [self.textView.text substringWithRange:fixedRange];
    NSString *tabStr = self.tabString;
    NSMutableString *mutStr = [NSMutableString new];
    [selectedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSRange firstTabRange = [line rangeOfString:tabStr];
        if (firstTabRange.location == 0) {
            line = [line stringByReplacingCharactersInRange:firstTabRange withString:@""];
        }
        [mutStr appendFormat:@"%@\n", line];
    }];
    NSString *resultStr = [mutStr substringToIndex:mutStr.length - 1];
    [self.textView replaceRange:[self textRangeFromNSRange:fixedRange] withText:resultStr];
}

- (void)menuActionShiftRight:(UIMenuItem *)sender {
    NSRange fixedRange = [self fixedSelectedTextRange];
    NSString *selectedText = [self.textView.text substringWithRange:fixedRange];
    NSString *tabStr = self.tabString;
    NSMutableString *mutStr = [[NSMutableString alloc] initWithString:tabStr];
    [selectedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        [mutStr appendFormat:@"%@\n%@", line, tabStr];
    }];
    NSString *resultStr = [mutStr substringToIndex:mutStr.length - tabStr.length - 1];
    [self.textView replaceRange:[self textRangeFromNSRange:fixedRange] withText:resultStr];
}

- (void)menuActionComment:(UIMenuItem *)sender {
    NSRange fixedRange = [self fixedSelectedTextRange];
    NSString *selectedText = [self.textView.text substringWithRange:fixedRange];
    __block BOOL hasComment = NO;
    [selectedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        if (line.length != 0) {
            hasComment = NO;
            for (NSUInteger i = 0; i < line.length - 1; i++) {
                char c1 = (char) [line characterAtIndex:i];
                char c2 = (char) [line characterAtIndex:i + 1];
                if (c1 == ' ' || c1 == '\t') {
                    continue;
                }
                if (c1 == '-' && c2 == '-') {
                    hasComment = YES;
                    break;
                } else {
                    hasComment = NO;
                    *stop = YES;
                }
            }
        }
    }];
    NSMutableString *mutStr = [NSMutableString new];
    if (hasComment) {
        [selectedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            NSString *testLine = [line stringByTrim];
            BOOL commentFirst = ([testLine rangeOfString:@"--"].location == 0);
            if (commentFirst) {
                NSRange firstCommentRange = [line rangeOfString:@"--"];
                if (firstCommentRange.location != NSNotFound) {
                    line = [line stringByReplacingCharactersInRange:firstCommentRange withString:@""];
                }
            }
            [mutStr appendFormat:@"%@\n", line];
        }];
    } else {
        [selectedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            [mutStr appendFormat:@"--%@\n", line];
        }];
    }
    NSString *resultStr = [mutStr substringToIndex:mutStr.length - 1];
    [self.textView replaceRange:[self textRangeFromNSRange:fixedRange] withText:resultStr];
}

#pragma mark - Auto Indent

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!self.autoIndent) return YES;
    if (text.length == 1 &&
        [text isEqualToString:@"\n"] &&
        _tabString.length != 0
        ) {
        BOOL hasBreak = ([text rangeOfString:@"\n"].location != NSNotFound);
        if (!hasBreak) return YES;
        
        NSString *stringRef = textView.text;
        NSRange lastBreak = [stringRef rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
        
        NSUInteger idx = lastBreak.location + 1;

        if (lastBreak.location == NSNotFound) idx = 0;
        else if (lastBreak.location + lastBreak.length == range.location) return YES;
        
        NSMutableString *tabStr = [NSMutableString new];
        for (; idx < range.location; idx++) {
            char thisChar = (char) [stringRef characterAtIndex:idx];
            if (thisChar != ' ' && thisChar != '\t') break;
            else [tabStr appendFormat:@"%c", (char)thisChar];
        }
        
        [self.textView insertText:[NSString stringWithFormat:@"\n%@", tabStr]];
        return NO;
    }
    else if (text.length == 0 &&
             range.length != 0 &&
             _tabString.length != 0)
    {}
    return YES;
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
