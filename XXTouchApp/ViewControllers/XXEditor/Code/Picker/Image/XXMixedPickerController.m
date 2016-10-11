//
//  XXMixedPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 10/10/16.
//  Copyright (c) 2016 Zheng. All rights reserved.
//

#import "XXMixedPickerController.h"
#import "XXImagePickerController.h"
#import "XXImagePickerPlaceholderView.h"
#import "XXCodeMakerService.h"
#import <Masonry/Masonry.h>
#import "PECropView.h"

@interface XXMixedPickerController () <DoImagePickerControllerDelegate>
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) XXImagePickerPlaceholderView *placeholderView;

@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, copy) NSString *keyword;

// Rect
@property (nonatomic, strong) PECropView *cropView;

@end

@implementation XXMixedPickerController {

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.navigationController isNavigationBarHidden]) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.pickerType == kXXImagePickerTypePosition) {
        self.title = NSLocalizedString(@"Position", nil);
        self.keyword = @"@pos@";
    } else if (self.pickerType == kXXImagePickerTypeColor) {
        self.title = NSLocalizedString(@"Color", nil);
        self.keyword = @"@color@";
    } else if (self.pickerType == kXXImagePickerTypeMixed) {
        self.title = NSLocalizedString(@"Mixed", nil);
        self.keyword = @"@poscolor@";
    } else if (self.pickerType == kXXImagePickerTypeRect) {
        self.title = NSLocalizedString(@"Rectangle", nil);
        self.keyword = @"@rect@";
    }
    
    [self.view addSubview:self.placeholderView];
    if (!self.selectedImage) {
        self.placeholderView.hidden = NO;
    }
    
    if (self.codeBlock) {
        self.navigationItem.rightBarButtonItem = self.nextButton;
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.placeholderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.height.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        self.navigationController.hidesBarsOnTap = NO;
        self.selectedImage = nil;
    } else {
        self.navigationController.hidesBarsOnTap = YES;
    }
}

#pragma mark - Getter

- (XXImagePickerPlaceholderView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[XXImagePickerPlaceholderView alloc] initWithFrame:self.view.bounds];
        _placeholderView.hidden = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(placeholderViewTapped:)];
        [_placeholderView addGestureRecognizer:tapGesture];
    }
    return _placeholderView;
}

- (UIBarButtonItem *)nextButton {
    if (!_nextButton) {
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Skip", nil) style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
        nextButton.tintColor = [UIColor whiteColor];
        _nextButton = nextButton;
    }
    return _nextButton;
}

- (void)next:(UIBarButtonItem *)sender {
    if (!self.selectedImage) {
        [self pushToNextControllerWithKeyword:self.keyword replacement:@""];
    } else {
        if (self.pickerType == kXXImagePickerTypeRect) {
            CGRect cropRect = self.cropView.zoomedCropRect;
            NSString *rectStr = [NSString stringWithFormat:@"%f, %f, %f, %f", cropRect.origin.x, cropRect.origin.y, cropRect.origin.x + cropRect.size.width, cropRect.origin.y + cropRect.size.height];
            [self pushToNextControllerWithKeyword:self.keyword replacement:rectStr];
        }
    }
}

- (void)pushToNextControllerWithKeyword:(NSString *)keyword
                            replacement:(NSString *)replace {
    XXCodeBlockModel *newBlock = [_codeBlock mutableCopy];
    NSString *code = newBlock.code;
    NSRange range = [code rangeOfString:keyword];
    if (range.length == 0) return;
    newBlock.code = [code stringByReplacingCharactersInRange:range withString:replace];
    [XXCodeMakerService pushToMakerWithCodeBlockModel:newBlock controller:self];
}

#pragma mark - Setter

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    if (!selectedImage) {
        self.fd_interactivePopDisabled = NO;
        self.nextButton.title = NSLocalizedString(@"Skip", nil);
        [self.cropView removeFromSuperview];
    } else {
        self.fd_interactivePopDisabled = YES;
        self.nextButton.title = NSLocalizedString(@"Next", nil);
        if (self.pickerType == kXXImagePickerTypeRect) {
            self.cropView = [[PECropView alloc] initWithFrame:self.view.bounds];
            self.cropView.image = selectedImage;
            [self.view addSubview:self.cropView];
        }
    }
}

#pragma mark - Tap Gesture

- (void)placeholderViewTapped:(UITapGestureRecognizer *)sender {
    XXImagePickerController *cont = [[XXImagePickerController alloc] initWithNibName:@"XXImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = 1;
    cont.nColumnCount = 4;
    [self presentViewController:cont animated:YES completion:nil];
}

#pragma mark - DoImagePickerControllerDelegate

- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(XXImagePickerController *)picker
                                            result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (aSelected.count == 0) {
        return;
    }
    if (self.placeholderView.hidden == NO) {
        self.placeholderView.hidden = YES;
    }
    self.selectedImage = aSelected[0];
}

@end
