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
#import "XXCodeBlocksViewController.h"
#import "XXBaseTextView.h"
#import "XXLocalNetService.h"
#import <Masonry/Masonry.h>
#import "XXKeyboardRow.h"

static NSString * const kXXErrorDomain = @"com.xxtouch.error-domain";
static NSString * const kXXBaseTextEditorPropertiesTableViewControllerStoryboardID = @"kXXBaseTextEditorPropertiesTableViewControllerStoryboardID";
static NSString * const kXXCodeBlocksTableViewControllerStoryboardID = @"kXXCodeBlocksTableViewControllerStoryboardID";

@interface XXBaseTextEditorViewController () <UITextViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UIView *fakeStatusBar;
@property (nonatomic, strong) XXBaseTextView *textView;
@property (nonatomic, copy) NSString *fileContent;
@property (nonatomic, strong) UIToolbar *bottomBar;

@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, assign) BOOL isLuaCode;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isEdited;

@end

@implementation XXBaseTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup {
    
    NSString *fileExt = [[self.filePath pathExtension] lowercaseString];
    if ([fileExt isEqualToString:@"lua"]) {
        _isLuaCode = YES;
    } else {
        _isLuaCode = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.fd_interactivePopDisabled = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = self.shareItem;
    
    [self.view addSubview:self.fakeStatusBar];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.bottomBar];
    [self updateViewConstraints];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *codeBlocksItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Code Snippets", nil) action:@selector(menuActionCodeBlocks:)];
    UIMenuItem *keywordsItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Keywords", nil) action:@selector(menuActionKeywords:)];
    [menuController setMenuItems:@[codeBlocksItem, keywordsItem]];
    
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSError *err = nil;
        BOOL result = [self loadFileWithError:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                self->_isLoaded = NO;
                self.bottomBar.userInteractionEnabled = NO;
                [self.navigationController.view makeToast:[err localizedDescription]];
            } else {
                self->_isLoaded = YES;
                self.bottomBar.userInteractionEnabled = YES;
            }
        });
    });
    
}

- (BOOL)loadFileWithError:(NSError **)err {
    NSNumber *fileSize = [FCFileManager sizeOfFileAtPath:self.filePath error:err];
    if (*err) {
        return NO;
    }
    
    // Size Limit
    NSUInteger fileSizeU = [fileSize unsignedIntegerValue];
    if (fileSizeU > 1024000) {
        GENERATE_ERROR(([NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" is too large to fit in the memory", nil), [self.filePath lastPathComponent]]));
        return NO;
    }
    
    self.fileContent = [FCFileManager readFileAtPath:self.filePath error:err];
    if (*err) {
        return NO;
    }
    
    // Set Text
    dispatch_async_on_main_queue(^{
        self.textView.text = self.fileContent;
    });
    return YES;
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
                                             selector:@selector(keyboardDidDismiss:)
                                                 name:UIKeyboardDidHideNotification
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
    [self saveFileWithError:&err];
}

- (BOOL)saveFileWithError:(NSError **)err {
    self.fileContent = self.textView.text;
    if (_isLoaded && _isEdited) {
        [FCFileManager writeFileAtPath:self.filePath content:self.fileContent error:err];
    }
    if (*err) {
        return NO;
    }
    return YES;
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

#pragma mark - Getters

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
        UIFont *font = [UIFont fontWithName:@"CourierNewPSMT" size:14.0f];
        
        XXBaseTextView *textView = [[XXBaseTextView alloc] initWithFrame:self.view.bounds];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.font = font;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        textView.alwaysBounceVertical = YES;
        textView.delegate = self;
        textView.tintColor = STYLE_TINT_COLOR;
        textView.selectedRange = NSMakeRange(0, 0);
        textView.contentOffset = CGPointZero;
        textView.contentInset =
        textView.scrollIndicatorInsets =
        UIEdgeInsetsMake(0, 0, self.bottomBar.height, 0);
        
        if (_isLuaCode) {
            textView.highlightLuaSymbols = YES;
            textView.inputAccessoryView = [[XXKeyboardRow alloc] initWithTextView:textView];
        } else {
            textView.highlightLuaSymbols = NO;
        }
        _textView = textView;
    }
    return _textView;
}

- (UIToolbar *)bottomBar {
    if (!_bottomBar) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *myToolBarItems = [NSMutableArray array];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-search"] style:UIBarButtonItemStyleBordered target:self action:@selector(search:)]];
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-reading"] style:UIBarButtonItemStyleBordered target:self action:@selector(reading:)]];
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-statistics"] style:UIBarButtonItemStyleBordered target:self action:@selector(statistics:)]];
        [myToolBarItems addObject:flexibleSpace];
        [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-settings"] style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)]];
        
        UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
        bottomBar.barStyle = UIBarStyleDefault;
        bottomBar.userInteractionEnabled = NO;
        [bottomBar setTintColor:STYLE_TINT_COLOR];
        [bottomBar setItems:myToolBarItems animated:YES];
        
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

- (UISearchController *)searchController {
    if (!_searchController) {
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        searchController.delegate = self;
        searchController.searchBar.delegate = self;
        searchController.searchResultsUpdater = self;
        searchController.dimsBackgroundDuringPresentation = NO;
        searchController.hidesNavigationBarDuringPresentation = NO;
        searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x, searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.width, 44.0);
        _searchController = searchController;
    }
    return _searchController;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return NO;
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
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
        [self.navigationController.view makeToast:NSLocalizedString(@"Cannot find supporting application", nil)];
    }
}

#pragma mark - Toolbar Actions

- (void)search:(UIBarButtonItem *)sender {
    [self.navigationController.view makeToast:NSLocalizedString(@"Not implemented", nil)];
}

- (void)reading:(UIBarButtonItem *)sender {
    if (!_isLuaCode) {
        [self.navigationController.view makeToast:NSLocalizedString(@"Unsupported file type", nil)];
        return;
    }
    self.navigationController.view.userInteractionEnabled = NO;
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        __block NSError *err = nil;
        BOOL result = [XXLocalNetService localCheckSyntax:self.fileContent error:&err];
        dispatch_async_on_main_queue(^{
            self.navigationController.view.userInteractionEnabled = YES;
            [self.navigationController.view hideToastActivity];
            if (!result) {
                if (err.code == 2) {
                    NSString *reason = [err localizedFailureReason];
                    [self.navigationController.view makeToast:reason];
                    [self scrollToLineByReason:reason];
                } else {
                    [self.navigationController.view makeToast:[err localizedDescription]];
                }
            } else {
                if (err.code == 0) {
                    [self.navigationController.view makeToast:NSLocalizedString(@"Syntax Check Passed", nil)];
                }
            }
        });
    });
}

- (void)scrollToLineByReason:(NSString *)reason {
    NSArray <NSString *> *arr = [reason componentsSeparatedByString:@":"];
    if (arr.count < 2) {
        return;
    }
    NSUInteger lineRange = [arr[0] unsignedIntegerValue] - 1;
    NSString *s = self.fileContent;
    NSUInteger index = 0;
    NSUInteger count = 0;
    NSUInteger l = [s length];
    for (int i = 0; i < l; i++) {
        char cc = [s characterAtIndex:i];
        if (cc == '\n') {
            count++;
            if (count == lineRange) {
                index = i;
            }
        }
    }
    [self.textView scrollRangeToVisible:NSMakeRange(index, 0)];
}

- (void)statistics:(UIBarButtonItem *)sender {
    XXBaseTextEditorPropertiesTableViewController *propertiesController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:kXXBaseTextEditorPropertiesTableViewControllerStoryboardID];
    propertiesController.filePath = self.filePath;
    propertiesController.fileContent = self.fileContent;
    [self.navigationController pushViewController:propertiesController animated:YES];
}

- (void)settings:(UIBarButtonItem *)sender {
    [self.navigationController.view makeToast:NSLocalizedString(@"Advanced Settings are not provided to XXTouch App Lite", nil)];
}

#pragma mark - Keyboard Events

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

- (void)keyboardDidDismiss:(NSNotification *)aNotification {
    self.textView.contentInset =
    self.textView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, self.bottomBar.height, 0);
    self.fileContent = self.textView.text;
    if (!_isEdited) _isEdited = YES;
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self updateViewConstraints];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - Menu Actions

- (void)menuActionCodeBlocks:(UIMenuItem *)sender {
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    UINavigationController *navController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:kXXCodeBlocksTableViewControllerStoryboardID];
    XXCodeBlocksViewController *codeBlocksController = (XXCodeBlocksViewController *)navController.topViewController;
    codeBlocksController.textInput = self.textView;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)menuActionKeywords:(UIMenuItem *)sender {
    
}

- (void)dealloc {
    CYLog(@"");
}

@end
