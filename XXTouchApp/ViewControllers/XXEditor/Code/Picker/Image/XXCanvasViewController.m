//
//  XXCanvasViewController.m
//  XXTouchApp
//
//  Created by Zheng on 18/10/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "XXCropView.h"
#import "XXCodeMakerService.h"
#import "XXLocalDataService.h"
#import "XXCanvasViewController.h"
#import "XXImagePickerController.h"
#import "XXImagePickerPlaceholderView.h"
#import "XXCodeBlockNavigationController.h"

@interface XXCanvasViewController () <XXImagePickerControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) XXImagePickerPlaceholderView *placeholderView;
@property (nonatomic, strong) UIToolbar *cropToolbar;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, copy) NSString *tempImagePath;
@end

@implementation XXCanvasViewController

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self isNavigationBarHidden]) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    if ([self isNavigationBarHidden]) {
        return YES;
    }
    return [super prefersStatusBarHidden];
}

#pragma mark - Rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    if (!self.selectedImage) {
        return;
    }
    self.selectedImage = self.selectedImage;
}

#pragma mark - Transition

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        // Out
        self.selectedImage = nil;
    } else {
        
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        
    } else {
        // Into
    }
}

- (void)next:(UIBarButtonItem *)sender {
    if (!self.selectedImage) {
        [self pushToNextControllerWithKeyword:[[self class] keyword] replacement:@""];
    } else {
        [self pushToNextControllerWithKeyword:[[self class] keyword] replacement:[self previewString]];
    }
}

#pragma mark - View & Constraints

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedImage = nil;
    self.title = self.localizedStrings[kXXLocalizedStringKeyTitle];
    [self loadImageFromCache];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.placeholderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.height.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    [self.cropToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(44));
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    [self.cropView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    XXCropView *cropView = [[XXCropView alloc] initWithFrame:contentView.bounds andType:[self cropViewType]];
    cropView.hidden = YES;
    _cropView = cropView;
    [contentView insertSubview:self.cropView atIndex:0];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tripleFingerTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 3;
    tapGesture.delegate = self;
    [self.cropView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.cropToolbar];
    [self.view addSubview:self.placeholderView];
}

#pragma mark - Image Cache

- (void)loadImageFromCache {
    if ([[NSFileManager defaultManager] isReadableFileAtPath:self.tempImagePath]) {
        NSError *err = nil;
        NSData *imageData = [NSData dataWithContentsOfFile:self.tempImagePath
                                                   options:NSDataReadingMappedIfSafe
                                                     error:&err];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                self.selectedImage = image;
            } else {
                self.subtitle = self.localizedStrings[kXXLocalizedStringKeyErrorLoadFile];
            }
        } else if (err) {
            self.subtitle = [err localizedDescription];
        }
    }
}

#pragma mark - Getter

- (kXXCropViewType)cropViewType {
    return kXXCropViewTypeRect;
}

- (NSDictionary <NSString *, NSString *> *)localizedStrings {
    if (!_localizedStrings) {
        _localizedStrings = @{};
    }
    return _localizedStrings;
}

- (XXImagePickerPlaceholderView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[XXImagePickerPlaceholderView alloc] initWithFrame:self.view.bounds];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(placeholderViewTapped:)];
        [_placeholderView addGestureRecognizer:tapGesture];
    }
    return _placeholderView;
}

- (UIToolbar *)cropToolbar {
    if (!_cropToolbar) {
        UIToolbar *cropToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.width, 44)];
        cropToolbar.hidden = YES;
        cropToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cropToolbar.tintColor = STYLE_TINT_COLOR;
        cropToolbar.backgroundColor = [UIColor clearColor];
        [cropToolbar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.f alpha:.75f]]
                     forToolbarPosition:UIBarPositionAny
                             barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *picBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"picker-pic"] style:UIBarButtonItemStylePlain target:self action:@selector(changeImageButtonTapped:)];
        UIBarButtonItem *toLeftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"picker-to-left"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateToLeftButtonTapped:)];
        UIBarButtonItem *toRightBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"picker-to-right"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateToRightButtonTapped:)];
        UIBarButtonItem *resetBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"picker-refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonTapped:)];
        UIBarButtonItem *trashBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-trash"] style:UIBarButtonItemStylePlain target:self action:@selector(trashButtonTapped:)];
        
        UIButton *lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
        [lockButton setImage:[[UIImage imageNamed:@"picker-unlock"] imageByTintColor:STYLE_TINT_COLOR] forState:UIControlStateNormal];
        [lockButton setImage:[[UIImage imageNamed:@"picker-lock"] imageByTintColor:STYLE_TINT_COLOR] forState:UIControlStateSelected];
        [lockButton setTarget:self
                       action:@selector(lockButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
        _lockButton = lockButton;
        UIBarButtonItem *lockBtn = [[UIBarButtonItem alloc] initWithCustomView:lockButton];
        
        [cropToolbar setItems:@[trashBtn, flexibleSpace, picBtn, flexibleSpace, toLeftBtn, flexibleSpace, toRightBtn, flexibleSpace, resetBtn, flexibleSpace, lockBtn]];
        
        _cropToolbar = cropToolbar;
    }
    return _cropToolbar;
}

- (NSString *)tempImagePath {
    if (!_tempImagePath) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *tempImagePath = [cachePath stringByAppendingPathComponent:@"kXXImagePickerTempImage.png"];
        _tempImagePath = tempImagePath;
    }
    return _tempImagePath;
}

#pragma mark - Setter

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    if (!selectedImage) {
        self.fd_interactivePopDisabled = NO;
        self.nextButton.title = NSLocalizedString(@"Skip", nil);
        self.cropToolbar.hidden = YES;
        self.cropView.hidden = YES;
        self.placeholderView.hidden = NO;
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeySelectImage];
    } else {
        self.fd_interactivePopDisabled = YES;
        if (self.codeBlock.currentStep == self.codeBlock.totalStep) {
            self.nextButton.title = NSLocalizedString(@"Done", nil);
        } else {
            self.nextButton.title = NSLocalizedString(@"Next", nil);
        }
        self.cropView.image = selectedImage;
        self.cropToolbar.hidden = NO;
        self.cropView.hidden = NO;
        self.placeholderView.hidden = YES;
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeySelected];
    }
}

#pragma mark - Tap Gestures

- (void)placeholderViewTapped:(id)sender {
    XXImagePickerController *cont = [[XXImagePickerController alloc] initWithNibName:@"XXImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = 1;
    cont.nColumnCount = 4;
    [self presentViewController:cont animated:YES completion:nil];
}

- (void)tripleFingerTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self setNavigationBarHidden:![self isNavigationBarHidden] animated:YES];
    }
}

- (BOOL)isNavigationBarHidden {
    return [self.navigationController isNavigationBarHidden];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
    if (hidden) {
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeyEnterFull];
    } else {
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeyExitFull];
    }
}

#pragma mark - Toolbar Actions

- (void)changeImageButtonTapped:(UIBarButtonItem *)sender {
    [self placeholderViewTapped:sender];
}

- (void)rotateToLeftButtonTapped:(UIBarButtonItem *)sender {
    if (!_selectedImage) return;
    self.selectedImage = [self.selectedImage imageByRotateLeft90];
}

- (void)rotateToRightButtonTapped:(UIBarButtonItem *)sender {
    if (!_selectedImage) return;
    self.selectedImage = [self.selectedImage imageByRotateRight90];
}

- (void)resetButtonTapped:(UIBarButtonItem *)sender {
    if (!_selectedImage || self.locked) return;
    if ([self.cropView userHasModifiedCropArea]) {
        [self.cropView resetCropRectAnimated:NO];
    }
}

- (void)lockButtonTapped:(id)sender {
    if (!_selectedImage) return;
    self.locked = self.lockButton.isSelected;
    if (self.locked) {
        self.locked = NO;
        self.cropView.allowsOperation = YES;
        self.lockButton.selected = NO;
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeyCanvasUnlocked];
    } else {
        self.locked = YES;
        self.cropView.allowsOperation = NO;
        self.lockButton.selected = YES;
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeyCanvasLocked];
    }
}

- (void)trashButtonTapped:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Discard Confirm", nil) andMessage:NSLocalizedString(@"Discard all changes and reset the canvas?", nil)];
    [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                          }];
    [alertView addButtonWithTitle:NSLocalizedString(@"Yes", nil)
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              [self setNavigationBarHidden:NO animated:YES];
                              [self cleanCanvas];
                          }];
    [alertView show];
}

#pragma mark - UIGestureRecognizerDelegate
#pragma mark - XXImagePickerControllerDelegate

- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(XXImagePickerController *)picker
                                            result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!aSelected || aSelected.count == 0) {
        [self cleanCanvas];
        return;
    }
    NSError *err = nil;
    NSData *imageData = UIImagePNGRepresentation(aSelected[0]);
    BOOL result = [imageData writeToFile:self.tempImagePath
                                 options:NSDataWritingAtomic
                                   error:&err];
    if (!result) {
        self.subtitle = [err localizedDescription];
    }
    self.selectedImage = aSelected[0];
}

- (void)cleanCanvas {
    self.selectedImage = nil;
    NSError *err = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:self.tempImagePath error:&err];
    if (!result) {
        self.subtitle = self.localizedStrings[kXXLocalizedStringKeyErrorDeleteFile];
    }
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
